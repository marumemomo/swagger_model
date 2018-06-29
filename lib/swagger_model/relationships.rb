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
            data = RelationData.new(relation_data)
          when 'Array'
            data = RelationDataArray.new(relation_data)
          end
          relationship = {
            'key' => key,
            'data' => data
          }
          @relationships.push(relationship)
        end
      end
      def to_swagger_hash(model, model_name)
        hash = {
          'type' => 'object'
        }
        properties = {}
        @relationships.each do |r|
          parent_name = model_name + 'Relationships'
          swagger_hash = r['data'].to_swagger_hash(r['key'], parent_name)
          name = swagger_hash.keys.first
          properties[r['key']] = {
            '$ref' => "#/definitions/#{name}"
          }
          model[name] = swagger_hash[name]
        end
        hash['properties'] = properties
        hash['required'] = properties.keys
        name = model_name + 'Relationships'
        model[name] = hash

        {
          '$ref' => "#/definitions/#{name}"
        }
      end
    end
  end
end
