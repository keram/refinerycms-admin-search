module Refinery
  module AdminSearch
    class << self
      def root
        @root ||= Pathname.new(File.expand_path('../../../', __FILE__))
      end
    end

    class Engine < Rails::Engine

      isolate_namespace Refinery

      engine_name :refinery_admin_search

      def search_form_partial_path
        'refinery/admin_search/search'
      end

      initializer "register refinery_admin_search engine" do
        Refinery::Core.admin_search = self

        Refinery::Core.config.register_admin_javascript 'refinery/admin/search'
      end

      config.to_prepare do
        Decorators.register! ::Refinery::AdminSearch.root
      end

    end
  end
end
