require_relative 'relationships'

module SwaggerModel
  module SwaggerV2
    class Attributes
      def initialize(hash, model_name, suffix='Attributes')
        @attributes = []
        @suffix = suffix
        @model_name = model_name
        hash.keys.each do |key|
          value = hash[key]
          attribute = get_attribute(value, key)
          @attributes.push(attribute)
        end
      end

      def to_swagger_hash(model)
        hash = {
          'type' => 'object'
        }
        properties = {}
        @attributes.each do |e|
          attribute = get_attribute_swagger(e, model)
          properties[e['key']] = attribute
        end
        hash['properties'] = properties
        hash['required'] = properties.keys
        name = @model_name + @suffix
        model[name] = hash
        {
          '$ref': "#/definitions/#{name}"
        }
      end

      private
      def get_attribute_swagger(e, model)
        attribute = {}
        type = e['type']
        key = e['key']
        case e['type']
        when 'object'
          name = ActiveSupport::Inflector.classify(key.gsub('-', '_'))
          attribute_name = @model_name + name + 'Attributes'
          attribute['$ref'] = "#/definitions/#{attribute_name}"
          e['attributes'].to_swagger_hash(model)
        when 'array'
          attribute['type'] = e['type']
          attribute['items'] = get_attribute_swagger(e['item'], model)
        else
          attribute['type'] = e['type']
          attribute['format'] = e['format'] unless e['format'].nil?
          attribute['example'] = e['example'] unless e['fexample'].nil?
        end
        attribute
      end
      def date_time_valid?(str)
        if (!! Date.parse(str) rescue false)
          date = Date._parse(str)
          !date[:zone].nil? && !date[:hour].nil? && !date[:min].nil? && !date[:sec].nil? && !date[:year].nil? && !date[:mon].nil?
        else
          false
        end
      end
      def get_attribute(value, key)
        attribute = {}
        type = get_type(value)
        case type
        when 'date-time'
          attribute = {
            'type' => 'string',
            'format' => 'date-time',
            'example' => value
          }
        when 'float'
          attribute = {
            'type' => 'number',
            'format' => 'float',
            'example' => value
          }
        when nil
          attribute = {
            'type' => 'UNKNOWN'
          }
        when 'object'
          name = ActiveSupport::Inflector.classify(key.gsub('-', '_'))
          attribute = {
            'type' => 'object',
            'attributes' => Attributes.new(value, @model_name + name)
          }
        when 'array'
          item = value.first
          attribute = {
            'type' => 'array',
            'item' => get_attribute(item, key)
          }
        else
          attribute = {
            'type' => type
          }
        end
        attribute['key'] = key
        attribute
      end
      def get_type(value)
        type_class = value.class.to_s
        case type_class
        when 'Hash'
          'object'
        when 'Array'
          'array'
        when 'String'
          if date_time_valid?(value)
            'date-time'
          else
            'string'
          end
        when 'Fixnum'
          'integer'
        when 'TrueClass', 'FalseClass'
          'boolean'
        when 'Float'
          'float'
        else
          nil
        end
      end
    end
  end
end
