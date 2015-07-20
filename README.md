## Framed Uploader

This is the Ruby client library for uploading custom data to the [Framed](http://framed.io/) data platform.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'framed_uploader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install framed_uploader

## Uploading user information

You can upload custom information about your users (ex: a dump of a users SQL table), which will be integrated
directly into Framed's machine learning models for making more accurate predictions.

The uploader can be used as a library from your application code, or with the bundled CLI runner.
You will need your API key, which you can get from your Framed dashboard.

As a library:

```ruby
require 'framed_uploader'

uploader = FramedUploader::Uploader.new("my-api-key")
uploader.upload("/path/to/users.csv")
```

Using the CLI:

Usage: `bundle exec framed-upload API_KEY [FILENAMES ...]`

Example:

```
bundle exec framed-upload abcd1234 users.csv
```

Please note that user data **must** be in a CSV-formatted file named `users.csv`, and there **must** be an
`id` column containing a value that uniquely identifies each user (ex: the primary key on a `users` table).
For example:

```
id,name,email
3,"John Smith","john@example.com"
18,"Jane Doe',"jane@example.com"
88,"Fred Flinstone","fred@example.com"
```
