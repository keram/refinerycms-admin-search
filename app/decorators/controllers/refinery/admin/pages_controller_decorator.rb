begin
  Refinery::Admin::PagesController.class_eval do
    before_action :search_all_pages, only: [:index], unless: -> {
      params[:search].blank? || params[:search].length < Refinery::SearchableRecord::MIN_SEARCHABLE_STRING_LENGTH
    }

    def search_all_pages
      @pages = Refinery::Page.search_by(params[:search], params[:search_in]).paginate(page: paginate_page, per_page: paginate_per_page)
    end
  end
rescue NameError
end
