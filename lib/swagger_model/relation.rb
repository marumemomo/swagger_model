require 'active_support'
require 'active_support/core_ext'

module SwaggerModel
  module SwaggerV2
    class Relation
      attr_accessor :type
      def initialize(hash)
        @type = hash['type']
      end

      def to_swagger_hash
        model_name = ActiveSupport::Inflector.classify(@type.gsub('-', '_'))
        {
            '$ref' => "#/definitions/#{model_name}"
        }
      end
    end
  end
end
