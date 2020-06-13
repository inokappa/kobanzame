# Kobanzame [![CircleCI](https://circleci.com/gh/inokappa/kobanzame.svg?style=svg)](https://circleci.com/gh/inokappa/kobanzame)

## About

![](https://raw.githubusercontent.com/inokappa/kobanzame/master/docs/images/fish_kobanzame.png)

Resource monitoring tool for ECS Task.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kobanzame'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kobanzame

## Usage

Write kobanzame.json.

```json
{
  "container": {
    "name": "batch-worker",
    "check_interval": 1,
    "report_format": "text"
  },
  "metrics": {
      "name": "cloudwatch",
      "namespace": "Custom/Kobanzame"
  },
  "outputs": [
    {
      "name": "cloudwatch_logs",
      "log_group_name": "kobanzame-sample",
      "log_stream_prefix": "kobanzame"
    }
  ]
}
```

Starting kobanzame.

```sh
$ kobanzame --config=kobanzame.json
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/kobanzame.
