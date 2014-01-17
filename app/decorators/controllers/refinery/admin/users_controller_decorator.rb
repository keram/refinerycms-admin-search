begin
  Refinery::Admin::UsersController.class_eval do
    before_action :search_all_users, only: [:index], unless: -> {
      params[:search].blank? || params[:search].length < 3
    }

    def search_all_users
      @users = paginate_all_users.search_by(params[:search], params[:search_in])
    end
  end
rescue NameError
end
