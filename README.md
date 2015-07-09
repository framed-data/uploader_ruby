# FramedUploader

Framed user CSV uploads for Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'framed_uploader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install framed_uploader

## Usage

Using the CLI runner script:

```ruby
bundle exec framed-upload API_KEY FILENAME
```

Or as a library:

```ruby
require 'framed_uploader'

uploader = FramedUploader::Uploader.new("my-api-key")
uploader.upload("/path/to/my-user-dump.csv")
```
