module SwaggerModel
  module SwaggerV2
    class RelationData
      def initialize(hash, parent_key)
        @relation = Relation.new(hash)
        @parent_key = parent_key
      end

      def to_swagger_hash
        name = ActiveSupport::Inflector.classify(@parent_key.gsub('-', '_')) + 'RelationData'
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
