require 'refinery/searchable_record'

begin
  Refinery::User.class_eval do
    extend Refinery::SearchableRecord
    acts_like_searchable :username, :email
  end
rescue NameError
end
