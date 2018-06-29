require_relative 'relation'

module SwaggerModel
  module SwaggerV2
    class RelationDataArray
      def initialize(array)
        @relation = Relation.new(array.first)
      end

      def to_swagger_hash(key, parent_name)
        name = parent_name + ActiveSupport::Inflector.classify(key.gsub('-', '_')) + 'Data'
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
