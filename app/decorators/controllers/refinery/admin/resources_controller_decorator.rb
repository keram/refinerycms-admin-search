begin
  Refinery::Admin::ResourcesController.class_eval do
    def search_all_resources
      @resources = search_all_records @resources
    end
  end
rescue NameError
end
