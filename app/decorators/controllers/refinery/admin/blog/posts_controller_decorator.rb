begin
  Refinery::Admin::Blog::PostsController.class_eval do
    def search_all_posts
      @posts = search_all_records(@posts).includes(:translations)
    end
  end
rescue NameError
end
