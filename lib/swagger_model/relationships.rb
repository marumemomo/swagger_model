module SwaggerModel
  module SwaggerV2
    class Relationships
      def initialize(hash)
        @relationships = {}
        hash.keys.each do |key|
          type_class = hash[key].class.to_s
          case type_class
          when 'Hash'
            
          when 'Array'
          end
        end
      end
    end
  end
end
