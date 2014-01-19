require 'refinery/searchable_record'

begin
  Refinery::Resource.class_eval do
    extend Refinery::SearchableRecord
    acts_like_searchable :file_name
  end
rescue NameError
end
