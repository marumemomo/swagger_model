require "swagger_model/version"
require 'json'
require 'yaml'
require 'date'

module SwaggerModel
  def self.date_time_valid?(str)
    if (!! Date.parse(str) rescue false)
      date = Date._parse(str)
      !date[:zone].nil? && !date[:hour].nil? && !date[:min].nil? && !date[:sec].nil? && !date[:year].nil? && !date[:mon].nil?
    else
      false
    end
  end

  def self.get_property(value)
    type_class = value.class.to_s
    obj = {}
    case type_class
    when 'Hash'
      obj['type'] = 'object'
      object = parse_object value
      obj['properties'] = object['properties']
      if object['required'].size > 0
        obj['required'] = object['required']
      end
    when 'Array'
      obj['type'] = 'array'
      obj['items'] = parse_array value
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

  def self.parse_array items
    m = {}
    value = items.first
    get_property(value)
  end

  def self.parse_object res
    keys = res.keys
    m = {}
    required = []
    for key in keys do
      value = res[key]
      m[key] = get_property(value)
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
    json_file_path = params[:json_file_path] || gets
    json = open(json_file_path) do |io|
      JSON.load(io)
    end
    model_name = params[:model_name] || File.basename(json_file_path, '.json')
    response = json
    model = {}
    model[model_name] = {}
    model[model_name]['type'] = "object"
    object = parse_object response
    model[model_name]['properties'] = object['properties']
    if object['required'].size > 0
      model[model_name]['required'] = object['required']
    end
    output_path = params[:output_path] || './'
    if params[:output_type] == 'json'
      File.write(File.join(output_path, "#{model_name}_model.json"), model.to_json)
    else
      File.write(File.join(output_path, "#{model_name}_model.yaml"), model.to_yaml)
    end
  end
end
