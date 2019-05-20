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
end
