require_relative 'relation_data'
require_relative 'relation_data_array'

module SwaggerModel
  module SwaggerV2
    class Relationships
      def initialize(hash)
        @relationships = []
        hash.keys.each do |key|
          relation_data = hash[key]['data']
          data = ''
          case relation_data.class.to_s
          when 'Hash'
            data = RelationData.new(relation_data, key)
          when 'Array'
            data = RelationDataArray.new(relation_data, key)
          end
          relationship = {
            'key' => key,
            'data' => data
          }
          @relationships.push(relationship)
        end
      end
      def to_swagger_hash(model)
        hash = {}
        @relationships.each do |r|
          swagger_hash = r['data'].to_swagger_hash
          model_name = swagger_hash.keys.first
          hash[r['key']] = {
            '$ref' => "#/definitions/#{model_name}"
          }
          model[model_name] = swagger_hash[model_name]
        end
        hash
      end
    end
  end
end
