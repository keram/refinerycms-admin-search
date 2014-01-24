begin
  Refinery::Admin::PagesController.class_eval do
    def search_all_pages
      @pages = search_all_records(@pages).includes(:translations)
    end
  end
rescue NameError
end
