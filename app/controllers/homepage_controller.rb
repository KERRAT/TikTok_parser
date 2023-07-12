class HomepageController < ApplicationController
  def home
  end

  def search
    @results = SearchService.new(search_params[:query]).call
    render :home
  end

  private

  def search_params
    params.require(:search).permit(:query)
  end
end
