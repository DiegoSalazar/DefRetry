[![Gem Version](https://badge.fury.io/rb/def_retry.svg)](http://badge.fury.io/rb/def_retry)

[![Build Status](https://travis-ci.org/DiegoSalazar/DefRetry.svg?branch=master)](https://travis-ci.org/DiegoSalazar/DefRetry)

# DefRetry

An expressive, fully spec'd gem to add the Retry Pattern to your methods and/or objects. With DefRetry
you can define methods with retry logic built-in or you can wrap your code in a
`retry` and specify options to customize the behavior.

## Installation

Add this line to your application's Gemfile:

    gem 'def_retry'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install def_retry

## Usage

### Defining a retryable method

```ruby
require 'def_retry'

class ApiWrapper
  include DefRetry

  def_retry :get_data, on: ApiError do
    do_api_call
  end
end
```

This will define an instance method named `:get_data` and rescue the exception
`ApiError` and retry the block:

```ruby
do
  do_api_call
end
```
3 times (the default).

### Retrying a block of code

```ruby
require 'def_retry'

class ApiWrapper
  include DefRetry

  def get_data
    @some_state = 'start'

    retryable on: ApiError do
      @some_state = 'working'
      do_api_call
      @some_state = 'done'
    end
  end
end
```

This will retry just that block of code.

### Don't want to mixin?

Use `DefRetry.retry` directly:

```ruby
require 'def_retry'

DefRetry.retry on: ApiError do
  do_api_call
end
```

### Create a Retrier with default options

```ruby
# config/intializers/retrier.rb
Retrier = DefRetry::Retrier.new({
  on: [ApiError, Timeout],
  tries: 7,
  on_retry: ->(exception, try_count) { Logger.debug exception },
  on_ensure: ->(value, try_count) { Logger.debug value, try_count },
  sleep: :exponential,
  re_raise: false
})

# later...
Retrier.run { do_api_call }
```

### Options

These apply to `.def_retry`, `#retryable`, `DefRetry.retry`, and `DefRetry::Retrier.new`:
  - `:on`: A single class or an array of exception classes to be rescued.
  - `:tries`: Integer number of maximum retries to run. DefRetry will stop retrying if the retry count reaches this number.
  - `:sleep`: Either an Integer to pass to `sleep`, a Proc that receives the current try count as its only argument or a Symbol naming one of these sleep strategies: constant, linear, exponential (see: `DefRetry::Retrier::SLEEP_STRATEGIES`).
  - `:on_retry`: A callback to run every time a retry happens i.e. the specified exception(s) are rescued. It will receive the exception that was rescued and the current try count as arguments, respectively.
  - `:on_ensure`: A callback to run at the end before returning the block's value. It will receive the block's return value and the current try count as arguments, respectively.
  - `:re_raise`: (default true) re raise the exception after done retrying.

## Contributing

1. Fork it ( https://github.com/DiegoSalazar/def_retry/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
