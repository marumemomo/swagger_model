require_relative 'relationships'
require_relative 'attributes'

module SwaggerModel
  module SwaggerV2
    class Model
      def initialize(hash)
        @id = hash['id']
        @type = hash['type']
        @model_name = ActiveSupport::Inflector.classify(@type.gsub('-', '_'))
        @attributes = Attributes.new(hash['attributes'], @model_name)
        if !hash['relationships'].nil?
          @relationships = Relationships.new(hash['relationships'])
        end
      end

      def to_swagger_hash(model)
        model[@model_name] = {}
        aModel = model[@model_name]
        hash = {
          'type' => 'object',
          'properties' => {
            'id' => {
              'type' => 'string',
              'example' => @id
            },
            'type' => {
              'type' => 'string',
              'example' => @type
            },
            'attributes' => @attributes.to_swagger_hash(aModel)
          },
          'required' => [
            'id',
            'type',
            'attributes'
          ]
        }
        unless @relationships.nil?
          hash['properties']['relationships'] = @relationships.to_swagger_hash(aModel, @model_name)
          hash['required'].push('relationships')
        end
        aModel[@model_name] = hash

        {
          '$ref' => "#/definitions/#{@model_name}"
        }
      end
    end
  end
end
