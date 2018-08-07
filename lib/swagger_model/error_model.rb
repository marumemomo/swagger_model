require_relative 'relationships'

module SwaggerModel
  module SwaggerV2
    class ErrorModel
      def to_swagger_hash
        {
          'type' => 'object',
          'properties' => {
            'status' => {
              'type' => 'string'
            },
            'meta' => {
              '$ref' => '#/definitions/ErrorModelMeta'
            }
          }
        }
      end
    end
  end
end
