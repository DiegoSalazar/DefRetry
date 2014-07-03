module DefRetry
  class Retrier
    DEFAULT_TRIES = 3
    SLEEP_STRATEGIES = {
      constant:    ->(n) { 1 },
      linear:      ->(n) { n },
      exponential: ->(n) { n**2 }
    }

    def initialize(options)
      @tries     = options.fetch :tries, DEFAULT_TRIES
      @on_retry  = options.fetch :on_retry, ->(e, n) {}
      @on_ensure = options.fetch :on_ensure, ->(r, n) {}
      @re_raise  = options.fetch :re_raise, true
      @sleep     = options.fetch :sleep, false

      begin
        @sleep = SLEEP_STRATEGIES.fetch @sleep if @sleep.is_a? Symbol
      rescue KeyError
        raise ArgumentError, "The :sleep option must be an Integer, a Proc, or a Symbol: #{SLEEP_STRATEGIES.keys.join(', ')}"
      end

      begin
        @exceptions = Array options.fetch(:on)
      rescue KeyError
        raise ArgumentError, 'You must specify which exceptions to retry :on'
      end
    end

    def run(&block)
      @try_count = 0
      @return = nil

      begin
        @return = block.call
      rescue *@exceptions => e
        @try_count += 1
        run_sleep_strategy if @sleep
        @on_retry.call e, @try_count

        @try_count < @tries ? retry : (@re_raise and raise)
      ensure
        @on_ensure.call @return, @try_count
        @return
      end
    end

    private

    def run_sleep_strategy
      sleep @sleep.is_a?(Fixnum) ? @sleep : @sleep.call(@try_count)
    end
  end
end
