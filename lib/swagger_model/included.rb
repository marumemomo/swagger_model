module SwaggerModel
  module SwaggerV2
    class Included
      attr_accessor :models

      def initialize(array)
        @models = array.map { |e| Model.new(e) }
      end

      def models_to_swagger_hash(model)
        @models.each do |e|
          e.to_swagger_hash(model)
        end
      end
    end
  end
end
