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
          "age": 24,
          "lang": null
        },
        "relationships": {
          "articles": {
            "data": [
              {
                "id": "1",
                "type": "articles"
              }
            ]
          }
        }
      },
      "links": {
        "self": "http://example.com?page=2",
        "first": "http://example.com?page=1",
        "prev": "http://example.com?page=1",
        "next": "http://example.com?page=3",
        "last": "http://example.com?page=100"
      },
      "included": [
        {
          "id": "1",
          "type": "articles",
          "attributes": {
            "title": "title",
            "published_at": "2018-05-30T11:00:00.000+09:00"
          }
        }
      ]
    }
    EOS
    result = SwaggerModel::SwaggerV2.create_from_json(json_string: json, output_path: './example/output/', response_name: "ExampleResponseV2")
  end
end
