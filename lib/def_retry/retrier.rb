module DefRetry
  class Retrier
    DEFAULT_LIMIT = 3
    SLEEP_STRATEGIES = {
      constant:    ->(n) { 1 },
      linear:      ->(n) { n },
      exponential: ->(n) { n**2 }
    }

    def initialize(options, block)
      @block     = block
      @limit     = options.fetch :limit, DEFAULT_LIMIT
      @on_retry  = options.fetch :on_retry, ->(e, n) {}
      @on_ensure = options.fetch :on_ensure, ->(r, n) {}
      @sleep     = options.fetch :sleep, false

      begin
        @sleep = SLEEP_STRATEGIES.fetch @sleep if @sleep.is_a? Symbol
      rescue KeyError
        raise ArgumentError, "The :sleep option must be a Proc or one of: #{SLEEP_STRATEGIES.keys.join(', ')}"
      end

      begin
        @exceptions = Array options.fetch(:on)
      rescue KeyError
        raise ArgumentError, 'You must specify which :exceptions to retry on'
      end
    end

    def run
      @retry_count = 0
      @return = nil

      begin
        @return = @block.call
      rescue *@exceptions => e
        @retry_count += 1
        sleep @sleep.call(@retry_count) if @sleep
        @on_retry.call e, @retry_count

        retry if @retry_count < @limit
      ensure
        @on_ensure.call @return, @retry_count
        @return
      end
    end
  end
end
