class HomepageController < ApplicationController
  def home
  end

  def search
    @results = LinkCollectorService.new(search_params).call
    @query = search_params[:query]
    @type = search_params[:type]
    render :home
  end

  private

  def search_params
    params.require(:search).permit(:query, :type, :amount)
  end
end
