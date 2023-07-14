class HomepageController < ApplicationController
  def index
  end

  def search
    @links_to_users = LinkCollectorService.new(search_params).call

    @results = UserProfileParserService.new(@links_to_users).call

    @query = search_params[:query]
    @amount = search_params[:amount]
    render :home
  end

  private

  def search_params
    params.require(:search).permit(:query, :amount)
  end
end
