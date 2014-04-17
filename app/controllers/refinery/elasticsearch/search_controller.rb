require 'foundation_link_renderer'

module Refinery
  module Elasticsearch
    class SearchController < ::ApplicationController

      # Display search results given the query supplied
      def show
        @query = params[:q]
        @results = Elasticsearch.search(params[:q], page:(params[:page] || '1').to_i)

        present(@page = Refinery::Page.find_by_link_url("/search"))
      end

    end
  end
end
