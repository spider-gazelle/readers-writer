require "./helper"

describe RWLock do
  it "should isolate writes from reads" do
    lock = RWLock.new

    spawn do
      lock.read { sleep 1 }
    end

    spawn do
      lock.read { sleep 1 }
    end

    Fiber.yield

    lock.readers.should eq(2)
    lock.write { lock.readers.should eq(0) }
    spawn do
      lock.read { sleep 1 }
    end

    Fiber.yield

    lock.readers.should eq(1)
  end

  it "should be reentrant" do
    lock = RWLock.new
    did_write = false

    spawn do
      lock.read { sleep 1 }
    end

    Fiber.yield

    lock.read do
      lock.readers.should eq(2)

      # then we decide that we need to modify something
      lock.write do
        lock.readers.should eq(1)
        did_write = true
      end
    end

    did_write.should eq(true)
  end
end
