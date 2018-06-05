# SwaggerModel

Convert json to swagger model yaml

Example.json
```json
{
  "user": {
    "name": "marumemomo",
    "age": 24
  },
  "message": "hello",
  "created_at": "2018-05-05T20:02:24.000+09:00",
  "updated_at": null
}

```

to Example_model.yaml
```yaml
---
Example:
  type: object
  properties:
    user:
      type: object
      properties:
        name:
          type: string
          example: marumemomo
        age:
          type: integer
          example: 24
      required:
      - name
      - age
    message:
      type: string
      example: hello
    created_at:
      type: string
      example: '2018-05-05T20:02:24.000+09:00'
      format: date-time
    updated_at:
      type: ''
      example: ''
  required:
  - user
  - message
  - created_at
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'swagger_model'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install swagger_model

## Usage

```ruby
require 'swagger_model'

json = <<-EOS
{
  "user": {
    "name": "marumemomo",
    "age": 24
  },
  "message": "hello",
  "created_at": "2018-05-05T20:02:24.000+09:00",
  "updated_at": null
}
EOS

SwaggerModel.create_from_json(json_string: json, output_path: './example/output/', response_name: "ExampleResponse")
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marumemomo/swagger_model.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
