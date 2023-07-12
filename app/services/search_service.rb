class SearchService
  def initialize(params)
    @search_params = params
  end

  def call
    tag = @search_params[:query]
    amount = @search_params[:amount]
    encoded_tag = CGI.escape(tag)
    url = URI("https://www.tiktok.com/tag/#{encoded_tag}")


    response = HTTP.get(url)
    doc = Nokogiri::HTML(response.body.to_s)

    # Array of possible values for data-e2e attribute
    data_e2e_values = ['challenge-item-username', 'video-user-name', 'search-card-user-link']

    # Find all elements with any of the data-e2e values and get their parent 'a' link hrefs
    links = data_e2e_values.flat_map do |value|
      elements = doc.css("[data-e2e='#{value}']")
      elements.map { |element| element.ancestors('a').first['href'] if element }
    end

    links.compact
  end
end
