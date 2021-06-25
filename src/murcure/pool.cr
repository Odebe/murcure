require "mutex"

# fork of Earl::Pool
module Murcure
  class Pool(A, M, S)
    include Earl::Artist(M)

    def initialize(@capacity : Int32, @agent_init_state : S)
      @workers = Array(A).new(@capacity)
      @mutex = Mutex.new
      @done = Channel(Nil).new
    end

    # Spawns workers in their dedicated `Fiber`. Blocks until all workers have
    # stopped.
    def call
      @capacity.times do |i|
        spawn do
          agent = A.new(@agent_init_state)
          @mutex.synchronize { @workers << agent }

          while agent.starting?
            puts "starting tcp worker №#{i}"
            agent.mailbox = @mailbox
            agent.start(link: self)
          end
        end
      end

      # @done.receive?

      # until @workers.empty?
      #   Fiber.yield
      # end
    end

    def call(message : M)
      raise "unreachable"
    end

    # Recycles and restarts crashed and unexpectedly stopped agents.
    def trap(agent : A, exception : Exception?) : Nil
      if exception
        # Logger.error(agent, exception)
        puts "worker crashed (#{exception.class.name})"
      elsif agent.running?
        puts  "worker stopped unexpectedly"
      end

      if running?
        return agent.recycle
      end

      @mutex.synchronize { @workers.delete(agent) }
    end

    # Asks each worker to stop.
    def terminate : Nil
      @workers.each do |agent|
        agent.stop rescue nil
      end

      unless @done.closed?
        @done.close
      end
    end
  end
end