require "mutex"

class RWLock
  def initialize
    @readers = 0
    @fibers = [] of Fiber
    @reader_lock = Mutex.new
    @writer_lock = Mutex.new
  end

  getter readers

  # Read locks
  def read
    current_fiber = Fiber.current
    begin
      @writer_lock.synchronize do
        @reader_lock.synchronize do
          @readers += 1
          @fibers << current_fiber
        end
      end

      yield
    ensure
      @reader_lock.synchronize do
        @readers -= 1

        # NOTE:: we cast index as it will always return an index
        @fibers.delete_at(@fibers.index(current_fiber).as(Int32))
      end
    end
  end

  # Write lock
  def synchronize
    write do
      yield
    end
  end

  def write
    write_ready = false
    current_fiber = Fiber.current

    @writer_lock.synchronize do
      loop do
        @reader_lock.synchronize do
          write_ready = true
          @fibers.each do |fiber|
            if fiber != current_fiber
              write_ready = false
              break
            end
          end
        end
        break if write_ready

        # Wait a short amount of time
        Fiber.yield
      end

      yield
    end
  end
end
