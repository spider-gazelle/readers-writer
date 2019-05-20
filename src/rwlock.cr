require "mutex"

class RWLock
  def initialize
    @reading = [] of Fiber
    @writing = [] of Fiber
    @reader_lock = Mutex.new
    @writer_lock = Mutex.new
  end

  # Read locks
  def read
    current_fiber = Fiber.current
    begin
      @writer_lock.synchronize do
        @reader_lock.synchronize { @reading << current_fiber }
      end

      yield
    ensure
      # NOTE:: we cast index as it will always return an index
      @reader_lock.synchronize do
        @reading.delete_at(@reading.index(current_fiber).as(Int32))
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

    begin
      @reader_lock.synchronize do
        @writing << current_fiber
      end

      @writer_lock.synchronize do
        loop do
          @reader_lock.synchronize { write_ready = (@reading - @writing).size == 0 }
          break if write_ready

          # Wait a short amount of time
          Fiber.yield
        end

        yield
      end
    ensure
      @reader_lock.synchronize do
        @writing.delete_at(@writing.index(current_fiber).as(Int32))
      end
    end
  end
end
