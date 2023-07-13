class LinkCollectorService
  SEARCH_SELECTOR = '[data-e2e="search-card-user-link"]'.freeze
  CHALLENGE_SELECTOR = "[data-e2e='challenge-item-avatar']".freeze
  VIDEO_SELECTOR = "[data-e2e='video-user-name']".freeze

  def initialize(params)
    @type = params[:query].first == '#' ? 'hashtag' : 'search'
    @query = params[:query]
    @amount = params[:amount].to_i
  end

  def call
    url = generate_link
    process_page(url)
  end

  private

  def process_page(url)
    driver = SeleniumDriver.instance.get_driver
    driver.navigate.to(url)
    sleep(3) if @type == "search"
    links = Set.new

    scroll_and_collect_links(driver, links)
  end

  def scroll_and_collect_links(driver, links)
    previous_scroll_height = driver.execute_script('return document.body.scrollHeight')

    while links.count < @amount
      driver.execute_script("window.scrollTo(#{previous_scroll_height}, document.body.scrollHeight)")
      new_scroll_height = monitor_scroll(driver, previous_scroll_height)
      new_links = extract_new_links(driver)

      links.merge(new_links)

      break if new_scroll_height == previous_scroll_height || links.count >= @amount

      previous_scroll_height = new_scroll_height
    end

    links.take(@amount)
  end

  def monitor_scroll(driver, previous_scroll_height)
    start_time = Time.now

    loop do
      sleep(1)
      new_scroll_height = driver.execute_script('return document.body.scrollHeight')
      return new_scroll_height if ((new_scroll_height - previous_scroll_height).abs > 200) || Time.now - start_time > 5
    end
  end

  def extract_new_links(driver)
    doc = Nokogiri::HTML(driver.page_source)

    selectors = @type == "search" ? [SEARCH_SELECTOR] : [CHALLENGE_SELECTOR, VIDEO_SELECTOR]

    #TODO: implement way to parse each time new data, not all page each load

    links = []
    selectors.each do |selector|
      links = extract_links(doc, selector, false)
      break unless links.empty?
    end

    links
  end

  def extract_links(doc, selector, search_in_ancestors)
    doc.css(selector).filter_map do |element|
      if search_in_ancestors
        element.ancestors('a').first['href']
      else
        element['href']
      end
    end
  end

  def generate_link
    encoded_query = CGI.escape(@query)

    if @type == 'hashtag'
      "https://www.tiktok.com/tag/#{encoded_query}"
    elsif @type == 'search'
      timestamp = (Time.now.to_f * 1000).to_i
      "https://www.tiktok.com/search?q=#{encoded_query}&t=#{timestamp}"
    end
  end
end
