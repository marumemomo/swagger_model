require_relative 'relationships'

module SwaggerModel
  module SwaggerV2
    class ErrorModelMeta
      def to_swagger_hash
        {
          'type' => 'object',
          'properties' => {
            'code' => {
              'type' => 'string'
            },
            'message' => {
              'type' => 'string'
            },
            'messages' => {
              'type' => 'array',
              'items' => {
                'type' => 'string'
              }
            }
          }
        }
      end
    end
  end
end
