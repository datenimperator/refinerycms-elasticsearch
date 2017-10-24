if Refinery::Elasticsearch.enable_for.include?('Refinery::Page')
  begin
    Refinery::Page.class_eval do
      include ::Refinery::Elasticsearch::Searchable

      define_mapping do
        {
          title: { type: 'string' },
          browser_title: { type: 'string', analyzer: 'snowball' },
          menu_title: { type: 'string' },
          meta_description: { type: 'string' },
          custom_teaser: { type: 'string', analyzer: 'snowball' },
          part: {
            type: 'object',
            properties: {
              body: { type: 'string', analyzer: 'snowball' }
            }
          },
          created_at: { type: 'date' },
          updated_at: { type: 'date' }
        }
      end

      def to_index
        return unless in_menu?
        {
          title: title,
          part: parts.map { |part| { body: strip_tags(part.body) } },
          custom_teaser: custom_teaser,
          browser_title: browser_title,
          menu_title: menu_title,
          meta_description: meta_description,
          created_at: created_at,
          updated_at: updated_at
        }
      end

      def self.indexable
        live
      end
    end
  rescue NameError
  end
end
