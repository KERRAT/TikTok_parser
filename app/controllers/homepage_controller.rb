class HomepageController < ApplicationController
  def home
  end

  def search
    @results = LinkCollectorService.new(search_params).call

    @query = search_params[:query]
    @amount = search_params[:amount]
    render :home
  end

  private

  def search_params
    params.require(:search).permit(:query, :amount)
  end
end
