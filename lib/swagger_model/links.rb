module SwaggerModel
  module SwaggerV2
    class Links
      def self.template
        {
          'type' => 'object',
          'properties' => {
            'self' => {
              'type' => "string",
              'example' => "http://example.com?page=2"
            },
            'first' => {
              'type' => "string",
              'example' => "http://example.com?page=1"
            },
            'prev' => {
              'type' => "string",
              'example' => "http://example.com?page=1"
            },
            'next' => {
              'type' => "string",
              'example' => "http://example.com?page=3"
            },
            'last' => {
              'type' => "string",
              'example' => "http://example.com?page=100"
            }
          },
          'required' => [
            'self',
            'first',
            'last'
          ]
        }
      end
    end
  end
end
