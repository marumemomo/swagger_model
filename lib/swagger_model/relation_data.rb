module SwaggerModel
  module SwaggerV2
    class RelationData
      def initialize(hash)
        @relation = Relation.new(hash)
      end

      def to_swagger_hash(key, parent_name)
        name = parent_name + ActiveSupport::Inflector.classify(key.gsub('-', '_')) + 'Data'
        {
          name => {
            'type' => 'object',
            'properties' => {
              'data' => @relation.to_swagger_hash
            }
          }
        }
      end
    end
  end
end
