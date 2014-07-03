require 'spec_helper'
require 'def_retry'

class MockRetryable
  include DefRetry

  def_retry :api_call, on: Exception do
    1 + 1 # expensive API call!
  end
end

describe DefRetry do
  context '.def_retry' do
    it 'defines an instance method' do
      expect(MockRetryable.new).to respond_to :api_call
    end
  end

  context '#retryable' do
    it "returns the block's value" do
      mocked = MockRetryable.new
      expect(mocked.retryable(on: Exception) { 2 + 2 }).to be 4
    end
  end
end

# Note: see retrier_spec.rb for full specs
