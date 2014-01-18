module Refinery
  module SearchableRecord

    MIN_SEARCHABLE_STRING_LENGTH = 3

    def acts_like_searchable(*attr_names)
      options = attr_names.extract_options!

      @localized_searchable_attributes = options[:localized] || []
      @nested_searchable_attributes = options[:nested] || []
      @searchable_attributes = attr_names | localized_searchable_attributes | nested_searchable_attributes

      (searchable_attributes - localized_searchable_attributes - nested_searchable_attributes).each do |atr|
        self.class.class_eval do
          define_method :"search_by_#{atr}" do |str|
            where( arel_table[atr].matches(str) )
          end
        end
      end

      localized_searchable_attributes.each do |atr|
        self.class.class_eval do
          define_method :"search_by_#{atr}" do |str|
            joins(:translations).where( translation_class.arel_table[atr].matches(str) )
          end
        end
      end

      nested_searchable_attributes.each do |atr|
        raise NoMethodError.new("Method search_by_#{atr} for nested searchable attribute was not found defined in #{self.name}.\n" +
                                "You must define it before calling acts_like_searchable.") unless self.respond_to?("search_by_#{atr}")
      end
    end

    def search_by str, col=nil
      str = str.to_s
      col = searchable_attributes.first if col.nil?

      return all unless respond_to?("search_by_#{col}") &&
                        str.gsub(/(%|_)/, '').length > MIN_SEARCHABLE_STRING_LENGTH

      str = "#{str}%" if str =~ /[^\%\_]\z/
      send "search_by_#{col}", str
    end

    def searchable_attributes
      @searchable_attributes ||= []
    end

    def localized_searchable_attributes
      @localized_searchable_attributes ||= []
    end

    def nested_searchable_attributes
      @nested_searchable_attributes ||= []
    end

  end
end
