require 'swagger_model'

describe 'read json' do
  it 'convert to SwaggerV2 model from json-api response which has data object' do
    json = <<-'EOS'
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
          },
          "auth": {
            "data": {
              "id": "AAAA-BBBB-CCCCCCCC-DDDDDDDDDDDD",
              "type": "auth"
            }
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
        },
        {
          "id": "AAAA-BBBB-CCCCCCCC-DDDDDDDDDDDD",
          "type": "auth",
          "attributes": {
            "credential": {
              "access_token": "ACCESS_TOKEN",
              "referesh_token": "REFRESH_TOKEN"
            },
            "created_at": "2018-06-30T11:00:00.000+09:00"
          }
        }
      ]
    }
    EOS
    result = SwaggerModel::SwaggerV2.create_from_json(json_string: json, output_path: './example/output/', response_name: "ExampleResponseV2")
  end

  it 'convert to SwaggerV2 model from json-api response which has data array' do
    json = <<-'EOS'
    {
      "data": [
        {
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
            },
            "auth": {
              "data": {
                "id": "AAAA-BBBB-CCCCCCCC-DDDDDDDDDDDD",
                "type": "auth"
              }
            }
          }
        }
      ],
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
        },
        {
          "id": "AAAA-BBBB-CCCCCCCC-DDDDDDDDDDDD",
          "type": "auth",
          "attributes": {
            "credential": {
              "access_token": "ACCESS_TOKEN",
              "referesh_token": "REFRESH_TOKEN"
            },
            "created_at": "2018-06-30T11:00:00.000+09:00"
          }
        }
      ],
      "meta": {
        "current-page": {
          "number": 1,
          "size": 20
        }
      }
    }
    EOS
    result = SwaggerModel::SwaggerV2.create_from_json(json_string: json, output_path: './example/output/', response_name: "ExampleV2ArrayResponse")
  end

  it 'create error model from json' do
    json = <<-'EOS'
    {
      "errors": {
        "status": "400"
      }
    }
    EOS
    result = SwaggerModel::SwaggerV2.create_from_json(json_string: json, output_path: './example/output/', response_name: "ErrorResponse")
  end
end
