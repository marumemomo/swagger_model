require_relative 'relationships'
require_relative 'attributes'

module SwaggerModel
  module SwaggerV2
    class Model
      attr_accessor :relationships, :type

      def initialize(hash)
        @id = hash['id']
        @type = hash['type']
        @model_name = ActiveSupport::Inflector.classify(@type.gsub('-', '_'))
        if !hash['attributes'].nil?
          @attributes = Attributes.new(hash['attributes'], @model_name)
        end
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
            }
          },
          'required' => [
            'id',
            'type'
          ]
        }
        unless @attributes.nil?
          hash['properties']['attributes'] = @attributes.to_swagger_hash(aModel)
          hash['required'].push('attributes')
        end
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
