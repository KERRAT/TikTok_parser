class UserProfileParserService
  TITLE_SELECTOR = 'h1[data-e2e="user-title"]'.freeze
  SUBTITLE_SELECTOR = 'h2[data-e2e="user-subtitle"]'.freeze
  FOLLOWERS_COUNT_SELECTOR = 'strong[data-e2e="followers-count"]'.freeze
  BIO_SELECTOR = 'h2[data-e2e="user-bio"]'.freeze
  EMAIL_REGEX = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/



  def initialize(user_links)
    @user_links = user_links
  end

  def call
    @user_links.map do |user_link|
      url = generate_url(user_link)
      process_profile(url)
    end
  end

  private

  def process_profile(url)
    response = HTTP.get(url)
    doc = Nokogiri::HTML(response.body.to_s)

    title = extract_title(doc)
    subtitle = extract_subtitle(doc)
    followers_count = extract_followers_count(doc)
    views_on_video = extract_view_count(doc)
    bio = extract_bio(doc)
    email = extract_email(bio)
    socials = extract_socials(doc, bio)

    user = User.new()
  end

  def extract_title(doc)
    element = doc.at_css(TITLE_SELECTOR)
    element.text.strip if element
  end

  def extract_subtitle(doc)
    element = doc.at_css(SUBTITLE_SELECTOR)
    element.text.strip if element
  end

  def extract_followers_count(doc)
    element = doc.at_css(FOLLOWERS_COUNT_SELECTOR)
    human_number = element.text.strip if element
    NumberConversionService.human_to_number(human_number)
  end

  def extract_bio(doc)
    element = doc.at_css(BIO_SELECTOR)
    element.text.strip if element
  end

  def extract_view_count(doc)
    #TODO extract view count on visible videos, get average int and return
  end

  def extract_email(bio)
    match = text.match(EMAIL_REGEX)
    match ? match[0] : nil
  end

  def extract_socials(doc, bio, base_links)
    element = doc.at_css('a[data-e2e="user-link"] span')
    link = element.text.strip if element
    social = base_links.select {|name, base_link| link.include?(base_link)}.keys.first
    { social => link }
  end

  def generate_url(user_link)
    "https://www.tiktok.com#{user_link}"
  end
end
