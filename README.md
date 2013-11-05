# Truncator [![Code Climate](https://codeclimate.com/github/freemanoid/truncator.png)](https://codeclimate.com/github/freemanoid/truncator) [![Build Status](https://travis-ci.org/freemanoid/truncator.png)](https://travis-ci.org/freemanoid/truncator)


Truncate you urls as much as possible

Works with **ruby >= 2.0**

## Installation

    gem 'truncator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install truncator

## Usage

It gives you one method to rule your URIs:

```ruby
Truncator::UrlParser.shorten_url(uri, truncation_length)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
