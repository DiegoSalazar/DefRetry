require 'spec_helper'
require 'def_retry/retrier'

describe DefRetry::Retrier do
  let :block_exception do
    -> {
      @retries ||= 0
      @retries += 1
      raise Exception
    }
  end

  context '#new' do
    it 'requires exceptions to be specified' do
      expect {
        DefRetry::Retrier.new({})
      }.to raise_error ArgumentError
    end

    it 'complains about invalid sleep strategies' do
      expect {
        DefRetry::Retrier.new({
          on: Exception,
          sleep: :invalid
        })
      }.to raise_error ArgumentError
    end
  end

  context '#run' do
    it 'executes the block and returns its value' do
      the_block = -> { :ran }
      retrier = DefRetry::Retrier.new({
        on: Exception
      })

      expect(retrier.run(&the_block)).to be :ran
    end

    it 'retries on exception :tries times' do
      retrier = DefRetry::Retrier.new({
        on: Exception,
        tries: 2,
        re_raise: false
      })

      retrier.run &block_exception
      expect(@retries).to be 2
    end

    it 'reraises the exception by default after done retrying' do
      retrier = DefRetry::Retrier.new({
        on: Exception
      })

      expect { retrier.run &block_exception }.to raise_error Exception
    end

    it 'raises unspecified exceptions' do
      retrier = DefRetry::Retrier.new({
        on: ArgumentError
      })

      expect { retrier.run &block_exception }.to raise_error Exception
    end

    it 'runs an on_retry callback' do
      retrier = DefRetry::Retrier.new({
        on: Exception,
        on_retry: ->(e, n) { @did_retry = :yes },
        re_raise: false
      })

      retrier.run &block_exception
      expect(@did_retry).to be :yes
    end

    it 'runs an on_ensure callback' do
      retrier = DefRetry::Retrier.new({
        on: Exception,
        on_ensure: ->(r, n) { @did_ensure = :yes }
      })

      retrier.run {}
      expect(@did_ensure).to be :yes
    end

    it 'passes the exception and retry count to on_retry' do
      retrier = DefRetry::Retrier.new({
        on: Exception,
        on_retry: ->(e, r) {
          @exception = e
          @retry_count = r
        },
        re_raise: false
      })

      retrier.run &block_exception
      expect(@exception).to be_kind_of Exception
      expect(@retry_count).to be 3 # default :tries
    end

    it 'passes the return value and retry count to on_ensure' do
      retrier = DefRetry::Retrier.new({
        on: Exception,
        on_ensure: ->(v, r) {
          @value = v
          @retry_count = r
        }
      })

      retrier.run { :ran }
      expect(@value).to be :ran
      expect(@retry_count).to be 0
    end
  end

  context '#run with :constant sleep strategy' do
    it 'sleeps for 2 seconds' do
      retrier = DefRetry::Retrier.new({
        on: Exception,
        sleep: :constant,
        # the 1st retry will sleep for 1 second
        # the 2nd retry will sleep for 1 second
        tries: 2,
        re_raise: false
      })

      start_time = Time.now.to_i
      retrier.run &block_exception
      end_time = Time.now.to_i

      expect(end_time - start_time).to be 2
    end
  end

  context '#run with :linear sleep strategy' do
    it 'sleeps for 3 seconds' do
      retrier = DefRetry::Retrier.new({
        on: Exception,
        sleep: :linear,
        # the 1st retry will sleep for 1 second
        # the 2nd retry will sleep for 2 seconds, and so on
        tries: 2,
        re_raise: false
      })

      start_time = Time.now.to_i
      retrier.run &block_exception
      end_time = Time.now.to_i

      expect(end_time - start_time).to be 3
    end
  end

  context '#run with :exponential sleep strategy' do
    it 'sleeps for 5 seconds' do
      retrier = DefRetry::Retrier.new({
        on: Exception,
        sleep: :exponential,
        # the 1st retry will sleep for 1**2 == 1 second
        # the 2nd retry will sleep for 2**2 == 4 seconds
        tries: 2,
        re_raise: false
      })

      start_time = Time.now.to_i
      retrier.run &block_exception
      end_time = Time.now.to_i

      expect(end_time - start_time).to be 5
    end
  end
end
