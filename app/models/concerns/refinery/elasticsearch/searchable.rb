require 'active_support/concern'

module Refinery
  module Elasticsearch
    module Searchable
      extend ActiveSupport::Concern

      def strip_tags(s)
        return nil if s.nil?
        s.gsub(/<[^>]*>/ui, ' ').gsub(/\s+/, ' ')
      end

      def index_document
        if self.respond_to?(:to_index)
          if document = self.to_index
            needs_update = !(self.previous_changes.keys & document.keys).empty?
            ::Refinery::Elasticsearch.initialized do |client|
              client.index({
                index: ::Refinery::Elasticsearch.index_name,
                type:  self.class.document_type,
                id:    self.id,
                body:  document
              })
            end if needs_update
          end
        end
      end

      def delete_document
        ::Refinery::Elasticsearch.initialized do |client|
          client.delete({
            index: ::Refinery::Elasticsearch.index_name,
            type:  self.class.document_type,
            id:    self.id
          })
        end
      end

      included do
        after_commit :index_document, on: :create
        after_commit :index_document, on: :update
        after_commit :delete_document, on: :destroy
        ::Refinery::Elasticsearch.searchable_classes << self
      end

      module ClassMethods
        def define_mapping(&block)
          @mapping = block.call
        end

        def mapping
          @mapping
        end

        def document_type
          @document_type ||= name.underscore.gsub('/', '-')
        end
      end
    end
  end
end
