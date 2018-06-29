require_relative 'relation'

module SwaggerModel
  module SwaggerV2
    class RelationDataArray
      def initialize(array, parent_key)
        @relation = Relation.new(array.first)
        @parent_key = parent_key
      end

      def to_swagger_hash
        name = ActiveSupport::Inflector.classify(@parent_key.gsub('-', '_')) + 'RelationDataArray'
        {
          name => {
            'type' => 'object',
            'properties' => {
              'data' => {
                'type' => 'array',
                'items' => @relation.to_swagger_hash
              }
            }
          }
        }
      end
    end
  end
end
