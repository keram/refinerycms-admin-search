begin
  Refinery::Admin::UsersController.class_eval do
    def search_all_users
      @users = search_all_records @users
    end
  end
rescue NameError
end
