Refinery::AdminController.class_eval do
  def search_all_records records
    valid_search, reason = records.valid_search? params[:search], params[:search_in]
    if valid_search
      records.search_by params[:search], params[:search_in]
    else
      flash.now[:error] = ::I18n.t(reason, scope: 'refinery.search')
      records.impossible_where
    end
  end
end
