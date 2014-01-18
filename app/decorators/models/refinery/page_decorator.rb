require 'refinery/searchable_record'

begin
  Refinery::Page.class_eval do
    extend Refinery::SearchableRecord
    acts_like_searchable localized: [:title]
  end
rescue NameError
end
