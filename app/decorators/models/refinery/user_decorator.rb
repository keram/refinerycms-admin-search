begin
  Refinery::User.class_eval do
    SEARCHABLE_ATTRIBUTES = [:username, :email]

    class << self

      def search_by str, col=nil
        col = col.presence || 'username'

        if respond_to?("search_by_#{col}")
          str = "#{str}%" if str =~ /[^\%\_]\z/
          send "search_by_#{col}", str
        end
      end

      def search_by_username username
        where( arel_table[:username].matches(username) )
      end

      def search_by_email email
        where( arel_table[:email].matches(email) )
      end
    end
  end
rescue NameError
end
