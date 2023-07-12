class SearchService
  def initialize(params)
    @search_params = params
  end

  def call
    [@search_params]
  end
end
