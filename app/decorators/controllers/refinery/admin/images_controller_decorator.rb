begin
  Refinery::Admin::ImagesController.class_eval do
    def search_all_images
      @images = search_all_records @images
    end
  end
rescue NameError
end
