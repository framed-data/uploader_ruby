# FramedUploader

Framd user CSV uploads for Ruby.

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

```ruby
uploader = FramedUploader::Uploader.new("my-api-key")
uploader.upload("/path/to/my-user-dump.csv")
```
