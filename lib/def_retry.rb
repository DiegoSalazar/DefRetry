require "def_retry/version"

module DefRetry
  autoload :Retrier, 'def_retry/retrier'

  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  def self.retry(options, &block)
    Retrier.new(options).run &block
  end

  module ClassMethods
    def def_retry(name, options = {}, &block)
      define_method name do |*args|
        DefRetry.retry options.merge(args: args), &block
      end
    end
  end

  module InstanceMethods
    def retryable(options = {}, &block)
      DefRetry.retry options, &block
    end
  end
end
