require_relative 'relation'

module SwaggerModel
  module SwaggerV2
    class RelationDataArray
      attr_accessor :relation
      def initialize(array)
        if array.size > 0
          @relation = Relation.new(array.first)
        end

      end

      def to_swagger_hash(key, parent_name)
        if @relation.nil?
          return nil
        end
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
