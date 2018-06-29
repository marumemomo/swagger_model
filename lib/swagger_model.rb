require "swagger_model/version"
require 'json'
require 'yaml'
require 'date'
require 'active_support'
require 'active_support/core_ext'
require 'fileutils'
require 'logger'

require_relative 'swagger_model/links'
require_relative 'swagger_model/relationships'
require_relative 'swagger_model/model'
require_relative 'swagger_model/included'
require_relative 'swagger_model/attributes'

module SwaggerModel
  module OpenAPIv3
    def self.date_time_valid?(str)
      if (!! Date.parse(str) rescue false)
        date = Date._parse(str)
        !date[:zone].nil? && !date[:hour].nil? && !date[:min].nil? && !date[:sec].nil? && !date[:year].nil? && !date[:mon].nil?
      else
        false
      end
    end

    def self.get_property(key, value, model, root_key)
      type_class = value.class.to_s
      obj = {}
      case type_class
      when 'Hash'
        if value.has_key?('id') && value.has_key?('type')
          model_name = ActiveSupport::Inflector.classify(value['type'].gsub('-', '_'))
          model[model_name] = {}
          object = parse_object(value, model, model_name)
          properties = object['properties']
          newProperties = {}
          newProperties['allOf'] = []
          newProperties['allOf'][0] = {}
          newProperties['allOf'][0]['$ref'] = '#/components/schemas/ModelBase'
          newProperties['allOf'][1] = {}
          newProperties['allOf'][1]['type'] = 'object'
          if object['required'].size > 0
              newProperties['allOf'][1]['required'] = object['required']
          end
          properties.delete('id')
          properties.delete('type')
          newProperties['allOf'][1]['properties'] = properties
          model[model_name][model_name] = newProperties
          obj['$ref'] = '#/components/schemas/' + model_name
        elsif key == 'attributes'
          object = parse_object(value, model, root_key)
          properties = object['properties']
          model_name = root_key + 'Attributes'
          model[root_key][model_name] = {}
          model[root_key][model_name]['type'] = 'object'
          model[root_key][model_name]['properties'] = properties
          if object['required'].size > 0
            model[root_key][model_name]['required'] = object['required']
          end
          obj['$ref'] = '#/components/schemas/' + model_name
        elsif key == 'relationships'
          object = parse_object(value, model, root_key)
          properties = object['properties']
          model_name = root_key + 'Relationships'
          model[root_key][model_name] = {}
          model[root_key][model_name]['type'] = 'object'
          model[root_key][model_name]['properties'] = properties
          if object['required'].size > 0
            model[root_key][model_name]['required'] = object['required']
          end
          obj['$ref'] = '#/components/schemas/' + model_name
        else
          object = parse_object(value, model, root_key)
          properties = object['properties']
          obj['type'] = 'object'
          obj['properties'] = properties
          if object['required'].size > 0
            obj['required'] = object['required']
          end
        end
      when 'Array'
        if key == 'included'
          obj['type'] = 'array'
          obj['items'] = {}
          obj['items']['oneOf'] = parse_array_with_multi_model(value, model, root_key)
        else
          obj['type'] = 'array'
          obj['items'] = parse_array(value, model, root_key)
        end
      when 'String'
        obj['type'] = 'string'
        obj['example'] = value
        if date_time_valid?(value)
          obj['format'] = 'date-time'
        end
      when 'Fixnum'
        obj['type'] = 'integer'
        obj['example'] = value
      when 'TrueClass', 'FalseClass'
        obj['type'] = 'boolean'
        obj['example'] = value
      when 'Float'
        obj['type'] = 'number'
        obj['format'] = 'float'
        obj['example'] = value
      else
        obj['type'] = ''
        obj['example'] = ''
      end
      obj
    end

    def self.parse_array(items, model, root_key)
      m = {}
      value = items.first
      get_property(nil, value, model, root_key)
    end

    def self.parse_array_with_multi_model(items, model, root_key)
      types = []
      items.each do |value|
        types.push(get_property(nil, value, model, root_key))
      end
      types
    end

    def self.parse_object(res, model, root_key)
      keys = res.keys
      m = {}
      required = []
      for key in keys do
        value = res[key]
        m[key] = get_property(key, value, model, root_key)
        if m[key]['type'] != ''
          unless (keys.include?('id') && keys.include?('type')) && (key == 'id' || key == 'type')
            required.push(key)
          end
        end
      end
      obj = {}
      obj['properties'] = m
      obj['required'] = required
      obj
    end
    def self.create_from_json(params)
      response = {}.to_json
      json_string = params[:json_string]
      if !json_string.nil?
        response = JSON.load(json_string)
      else
        json_file_path = params[:json_file_path] || gets
        json = open(json_file_path) do |io|
          JSON.load(io)
        end
        response = json
      end
      response_name = params[:response_name] || gets
      response_model = {}
      response_model[response_name] = {}
      response_model[response_name]['type'] = "object"
      model = {}
      object = parse_object(response, model, response_name)
      properties = object['properties']
      if properties.has_key?('links')
        links = {}
        links['$ref'] = '#/components/schemas/Links'
        properties['links'] = links
      end
      if properties.has_key?('meta')
        meta_name = response_name + 'Meta'
        response_model[meta_name] = properties['meta']
        meta = {}
        meta['$ref'] = '#/components/schemas/' + meta_name
        properties['meta'] = meta
      end
      response_model[response_name]['properties'] = properties
      if object['required'].size > 0
        response_model[response_name]['required'] = object['required']
      end
      output_path = params[:output_path] || './'
      output_path_responses = File.join(output_path, 'Responses/')
      output_path_models = File.join(output_path, 'Models/')

      FileUtils::mkdir_p output_path_responses
      FileUtils::mkdir_p output_path_models

      File.write(File.join(output_path_responses, "#{response_name}.yaml"), response_model.to_yaml)

      keys = model.keys
      for key in keys do
        File.write(File.join(output_path_models, "#{key}.yaml"), model[key].to_yaml)
      end
    end
  end

  module SwaggerV2
    @logger = Logger.new(STDOUT)
    def self.date_time_valid?(str)
      if (!! Date.parse(str) rescue false)
        date = Date._parse(str)
        !date[:zone].nil? && !date[:hour].nil? && !date[:min].nil? && !date[:sec].nil? && !date[:year].nil? && !date[:mon].nil?
      else
        false
      end
    end

    def self.get_property(key, value, model, root_key)
      type_class = value.class.to_s
      obj = {}
      case type_class
      when 'Hash'
        if value.has_key?('id') && value.has_key?('type')
          model_name = ActiveSupport::Inflector.classify(value['type'].gsub('-', '_'))
          model[model_name] = {}
          object = parse_object(value, model, model_name)
          properties = object['properties']
          newProperties = {}
          newProperties['type'] = 'object'
          if object['required'].size > 0
              newProperties['required'] = object['required']
          end
          newProperties['properties'] = properties
          model[model_name][model_name] = newProperties
          obj['$ref'] = '#/definitions/' + model_name
        elsif key == 'attributes'
          object = parse_object(value, model, root_key)
          properties = object['properties']
          model_name = root_key + 'Attributes'
          model[root_key][model_name] = {}
          model[root_key][model_name]['type'] = 'object'
          model[root_key][model_name]['properties'] = properties
          if object['required'].size > 0
            model[root_key][model_name]['required'] = object['required']
          end
          obj['$ref'] = '#/definitions/' + model_name
        elsif key == 'relationships'
          relationships = Relationships.new(value)
          obj = relationships.to_swagger_hash(model, root_key)
        else
          object = parse_object(value, model, root_key)
          properties = object['properties']
          obj['type'] = 'object'
          obj['properties'] = properties
          if object['required'].size > 0
            obj['required'] = object['required']
          end
        end
      when 'Array'
        obj['type'] = 'array'
        obj['items'] = parse_array(value, model, root_key)
      when 'String'
        obj['type'] = 'string'
        obj['example'] = value
        if date_time_valid?(value)
          obj['format'] = 'date-time'
        end
      when 'Fixnum'
        obj['type'] = 'integer'
        obj['example'] = value
      when 'TrueClass', 'FalseClass'
        obj['type'] = 'boolean'
        obj['example'] = value
      when 'Float'
        obj['type'] = 'number'
        obj['format'] = 'float'
        obj['example'] = value
      else
        @logger.warn("Unrecognized Type of `#{key}`. [key: #{key}, root_key: #{root_key}]")
        obj['type'] = ''
        obj['example'] = ''
      end
      obj
    end

    def self.parse_array(items, model, root_key)
      m = {}
      value = items.first
      get_property(nil, value, model, root_key)
    end

    def self.parse_array_with_multi_model(items, model, root_key)
      types = []
      refs = []
      items.each do |value|
        property = get_property(nil, value, model, root_key)
        if !refs.include?(property['$ref'])
          types.push(get_property(nil, value, model, root_key))
          refs.push(property['$ref'])
        end
      end
      types
    end

    def self.parse_object(res, model, root_key)
      keys = res.keys
      m = {}
      required = []
      for key in keys do
        value = res[key]
        m[key] = get_property(key, value, model, root_key)
        if m[key]['type'] != ''
          required.push(key)
        end
      end
      obj = {}
      obj['properties'] = m
      obj['required'] = required
      obj
    end
    def self.create_from_json(params)
      response = {}.to_json
      json_string = params[:json_string]
      if !json_string.nil?
        response = JSON.load(json_string)
      else
        json_file_path = params[:json_file_path] || gets
        json = open(json_file_path) do |io|
          JSON.load(io)
        end
        response = json
      end
      response_name = params[:response_name] || gets
      response_model = {}
      response_model[response_name] = {}
      response_model[response_name]['type'] = "object"
      response_model[response_name]['properties'] = {}
      model = {}

      # Create response data
      if response.has_key?('data')
        data = response['data']
        case data.class.to_s
        when 'Hash'
          m = Model.new(data)
          response_model[response_name]['properties']['data'] = m.to_swagger_hash(model)
        when 'Array'
          m = Model.new(data.first)
          response_model[response_name]['properties']['data'] = {
            'type' => 'array',
            'items' => m.to_swagger_hash(model)
          }
        end
      end

      # Create included key models but not add included key to response
      if response.has_key?('included')
        included = Included.new(response['included'])
        included.models_to_swagger_hash(model)
      end

      # Create links from template
      if response.has_key?('links')
        links = {}
        links['$ref'] = '#/definitions/Links'
        response_model[response_name]['properties']['links'] = links
        if response_model['Links'].nil?
          response_model['Links'] = Links.template
        end
      end

      # Create Meta
      if response.has_key?('meta')
        meta_name = response_name + 'Meta'
        meta = Attributes.new(response['meta'], meta_name, '')
        meta.to_swagger_hash(response_model)
        meta = {}
        meta['$ref'] = '#/definitions/' + meta_name
        response_model[response_name]['properties']['meta'] = meta
      end

      # Set required
      response_model[response_name]['required'] = response_model[response_name]['properties'].keys

      # add example
      response_model[response_name]['example'] = response

      output_path = params[:output_path] || './'
      output_path_responses = File.join(output_path, 'Responses/')
      output_path_models = File.join(output_path, 'Models/')

      FileUtils::mkdir_p output_path_responses
      FileUtils::mkdir_p output_path_models

      File.write(File.join(output_path_responses, "#{response_name}.yaml"), response_model.to_yaml)

      keys = model.keys
      for key in keys do
        File.write(File.join(output_path_models, "#{key}.yaml"), model[key].to_yaml)
      end

      models = {}
      for key in keys do
        models[key] = model[key]
      end
      result = {
        "responses" => response_model,
        "models" => models
      }
    end
  end
end
