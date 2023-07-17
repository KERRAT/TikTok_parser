class HomepageController < ApplicationController
  def index
  end

  def search
    @links_to_users = LinkCollectorService.new(search_params).call

    @users = @links_to_users.map do |link|
      UserProfileUpdaterService.new(link).call
    end.compact

    @query = search_params[:query]
    @amount = search_params[:amount]

    render :index
  end

  private

  def search_params
    params.require(:search).permit(:query, :amount)
  end
end
