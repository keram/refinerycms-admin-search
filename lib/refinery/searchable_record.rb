module Refinery
  module SearchableRecord

    MIN_SEARCHABLE_STRING_LENGTH = 3
    MAX_SEARCHABLE_STRING_LENGTH = 128
    SEARCH_WILDCARDS = ['%', '^', '*', '_']
    SEARCH_WILDCARDS_RE = Regexp.new(SEARCH_WILDCARDS.map {|s| Regexp.escape(s) }.join('|'))
    MAX_WILDCARDS = 3

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
            joins(:translations).
            where( translation_class.arel_table[:locale].eq(::Globalize.locale) ).
            where( translation_class.arel_table[atr].matches(str) )
          end
        end
      end

      nested_searchable_attributes.each do |atr|
        raise NoMethodError.new("Method search_by_#{atr} for nested searchable attribute was not found defined in #{self.name}.\n" +
                                "You must define it before calling acts_like_searchable.") unless self.respond_to?("search_by_#{atr}")
      end
    end

    def search_by str, col=nil
      col ||= searchable_attributes.first
      send "search_by_#{col}", liberalize_search(str)
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

    def impossible_where
      where('1 = 2')
    end

    def valid_search? str, col=nil
      col ||= searchable_attributes.first
      return false, 'not_respond' unless respond_to?("search_by_#{col}")
      return false, 'search_string_is_too_short' if str.to_s.gsub(SEARCH_WILDCARDS_RE, '').length < MIN_SEARCHABLE_STRING_LENGTH
      return false, 'search_string_is_too_long' if str.length > MAX_SEARCHABLE_STRING_LENGTH
      return false, 'too_many_wildcards' if SEARCH_WILDCARDS.inject(0) {|a, s| a + str.count(s) } > MAX_WILDCARDS
      true
    end

    private

    def liberalize_search str
      str = "%#{str}" unless str =~ /\A(\%|\^)/
      str = str.sub(/\A\^/, '')
      str = "#{str}%" unless str =~ /(\%|\^)\z/
      str = str.sub(/\^\z/, '')
    end

  end
end
