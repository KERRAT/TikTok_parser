class SearchService
  def initialize(params)
    @type = params[:type]
    @query = params[:query]
    @amount = params[:amount]
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

    while links.count < @amount.to_i
      driver.execute_script("window.scrollTo(#{previous_scroll_height}, document.body.scrollHeight)")
      new_scroll_height = monitor_scroll(driver, previous_scroll_height)
      new_links = extract_new_links(driver)

      links.merge(new_links.compact)

      break if new_scroll_height == previous_scroll_height || links.count >= @amount.to_i

      previous_scroll_height = new_scroll_height
    end

    links.take(@amount.to_i)
  end

  def monitor_scroll(driver, previous_scroll_height)
    start_time = Time.now
    new_scroll_height = nil

    loop do
      sleep(1)
      new_scroll_height = driver.execute_script('return document.body.scrollHeight')
      break if new_scroll_height != previous_scroll_height || Time.now - start_time > 10
    end
    new_scroll_height
  end

  def extract_new_links(driver)
    doc = Nokogiri::HTML(driver.page_source)

    if @type == "search"
      extract_links(doc, '[data-e2e="search-card-user-link"]')
    else
      extract_links(doc, "[data-e2e='challenge-item-avatar']")
    end
  end

  def extract_links(doc, selector)
    elements = doc.css(selector)
    elements.map { |element| element['href'] if element }
  end

  def generate_link
    encoded_query = CGI.escape(@query)

    if @type == 'tag'
      URI("https://www.tiktok.com/tag/#{encoded_query}")
    elsif @type == 'search'
      timestamp = (Time.now.to_f * 1000).to_i
      URI("https://www.tiktok.com/search?q=#{encoded_query}&t=#{timestamp}")
    end
  end
end
