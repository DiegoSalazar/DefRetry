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

### Options

These apply to both `.def_retry` and `#retry`:
  - `:on`: a single class or an array of exception classes to be rescued
  - `:tries`: Integer number of maximum retries to run. DefRetry will stop retrying if the retry count reaches this number
  - `:sleep`: Either a Proc that receives the current try count as its only argument or a Symbol naming one of these sleep strategies: constant, linear, exponential (see: `DefRetry::Retrier::SLEEP_STRATEGIES`)
  - `:on_retry`: a callback to run everytime a retry happens i.e. the specified exception(s) are rescued
  - `:on_ensure`: a callback to run at the end before returning the block's value

## Contributing

1. Fork it ( https://github.com/DiegoSalazar/def_retry/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
