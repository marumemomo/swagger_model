require 'swagger_model'

describe 'read json' do
  it 'convert to OpenAPIv3 model from json string' do
    json = <<-EOS
    {
      "data": {
        "id": "id",
        "type": "users",
        "attributes": {
          "name": "marumemomo",
          "age": 24
        }
      }
    }
    EOS
    SwaggerModel::OpenAPIv3.create_from_json(json_string: json, output_path: './example/output/', response_name: "ExampleResponse")
  end

  it 'convert to SwaggerV2 model from json string' do
    json = <<-EOS
    {
      "data": {
        "id": "id",
        "type": "users",
        "attributes": {
          "name": "marumemomo",
          "age": 24
        }
      }
    }
    EOS
    SwaggerModel::SwaggerV2.create_from_json(json_string: json, output_path: './example/output/', response_name: "ExampleResponseV2")
  end
end
