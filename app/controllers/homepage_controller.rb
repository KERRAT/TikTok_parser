class HomepageController < ApplicationController
  def home
  end

  def search
    @results = SearchService.new(search_params).call
    @query = search_params[:query]
    render :home
  end

  private

  def search_params
    params.require(:search).permit(:query)
  end
end
