require 'swagger_model'

describe 'read json' do
  it 'json from string' do
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
  end
end
