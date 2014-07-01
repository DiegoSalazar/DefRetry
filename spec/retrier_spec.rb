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
        DefRetry::Retrier.new({}, -> {})
      }.to raise_error ArgumentError
    end

    it 'complains about invalid sleep strategies' do
      expect {
        DefRetry::Retrier.new({
          on: Exception,
          sleep: :invalid
        }, -> {})
      }.to raise_error ArgumentError
    end
  end

  context '#run' do
    it 'executes the block and returns its value' do
      the_block = -> { :ran }
      retrier = DefRetry::Retrier.new({
        on: Exception
      }, the_block)

      expect(retrier.run).to be :ran
    end

    it 'retries on exception :limit times' do
      retrier = DefRetry::Retrier.new({
        on: Exception,
        tries: 2
      }, block_exception)

      retrier.run
      expect(@retries).to be 2
    end

    it 'raises unspecified exceptions' do
      retrier = DefRetry::Retrier.new({
        on: ArgumentError
      }, block_exception)

      expect { retrier.run }.to raise_error Exception
    end

    it 'runs an on_retry callback' do
      retrier = DefRetry::Retrier.new({
        on: Exception,
        on_retry: ->(e, n) { @did_retry = :yes }
      }, block_exception)

      retrier.run
      expect(@did_retry).to be :yes
    end

    it 'runs an on_ensure callback' do
      retrier = DefRetry::Retrier.new({
        on: Exception,
        on_ensure: ->(r, n) { @did_ensure = :yes }
      }, -> {})

      retrier.run
      expect(@did_ensure).to be :yes
    end

    it 'passes the exception and retry count to on_retry' do
      retrier = DefRetry::Retrier.new({
        on: Exception,
        on_retry: ->(e, r) {
          @exception = e
          @retry_count = r
        }
      }, block_exception)

      retrier.run
      expect(@exception).to be_kind_of Exception
      expect(@retry_count).to be 3 # default limit
    end

    it 'passes the return value and retry count to on_ensure' do
      retrier = DefRetry::Retrier.new({
        on: Exception,
        on_ensure: ->(v, r) {
          @value = v
          @retry_count = r
        }
      }, -> { :ran })

      retrier.run
      expect(@value).to be :ran
      expect(@retry_count).to be 0 # default limit
    end
  end

  context '#run with :constant sleep strategy' do
    it 'sleeps for 2 seconds' do
      retrier = DefRetry::Retrier.new({
        on: Exception,
        sleep: :constant,
        # the 1st retry will sleep for 1 second
        # the 2nd retry will sleep for 1 second
        tries: 2
      }, block_exception)

      start_time = Time.now.to_i
      retrier.run
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
        tries: 2
      }, block_exception)

      start_time = Time.now.to_i
      retrier.run
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
        tries: 2
      }, block_exception)

      start_time = Time.now.to_i
      retrier.run
      end_time = Time.now.to_i

      expect(end_time - start_time).to be 5
    end
  end
end
