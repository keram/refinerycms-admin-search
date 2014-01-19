require 'refinery/searchable_record'

begin
  Refinery::Image.class_eval do
    extend Refinery::SearchableRecord
    acts_like_searchable :image_name, localized: [:alt, :caption]
  end
rescue NameError
end
