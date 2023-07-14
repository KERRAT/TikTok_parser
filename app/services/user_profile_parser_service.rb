class UserProfileParserService
  TITLE_SELECTOR = 'h1[data-e2e="user-title"]'.freeze
  SUBTITLE_SELECTOR = 'h2[data-e2e="user-subtitle"]'.freeze
  FOLLOWERS_COUNT_SELECTOR = 'strong[data-e2e="followers-count"]'.freeze
  BIO_SELECTOR = 'h2[data-e2e="user-bio"]'.freeze
  VIEWS_COUNT_SELECTOR = 'strong[data-e2e="video-views"]'.freeze
  EMAIL_REGEX = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/

  def initialize(user_links)
    @user_links = user_links
  end

  def call
    @user_links.map do |user_link|
      url = generate_url(user_link)
      process_profile(url)
    end.compact
  end

  private

  def process_profile(url)
    response = HTTP.get(url)
    doc = Nokogiri::HTML(response.body.to_s)

    title = extract_title(doc)

    user = User.find_or_initialize_by(title: title) || User.new(title: title)

    # Extract the rest of the data
    subtitle = extract_subtitle(doc)
    followers_count = extract_followers_count(doc)
    views_on_video = extract_view_count(doc)
    bio = extract_bio(doc)
    email = extract_email(bio)
    socials = extract_socials(doc, bio)

    user.update(
      subtitle: subtitle,
      followers: followers_count,
      views_on_video: views_on_video,
      bio: bio,
      email: email
    )

    socials.each do |name, url|
      social_network = SocialNetwork.find_by(name: name)

      user_social = UserSocial.find_or_initialize_by(user: user, social_network: social_network)
      user_social.update(url: url)
    end

    user
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
    elements = doc.css(VIEWS_COUNT_SELECTOR)
    total_views = 0
    elements.each do |element|
      view_count = NumberConversionService.human_to_number(element.text.strip)
      total_views += view_count
    end

    average_views = elements.count.positive? ? total_views.to_f / elements.count : 0

    average_views.to_i
  end

  def extract_email(bio)
    if bio
      match = bio.match(EMAIL_REGEX)
      match ? match[0] : nil
    else
      nil
    end
  end


  def extract_socials(doc, bio)
    element = doc.at_css('a[data-e2e="user-link"] span')

    if element
      link = element.text.strip
      link = 'https://' + link unless link.start_with?('http://', 'https://')
    end

    base_links = SocialNetwork.pluck(:name, :base_link).to_h
    social_links = {}

    base_links.each do |name, base_link|
      regex = Regexp.new("(http://|https://)?#{Regexp.escape(base_link)}\\S*", "i")
      match = bio.match(regex)

      if match
        found_link = match[0]
        found_link = 'https://' + found_link unless found_link.start_with?('http://', 'https://')
        social_links[name] = found_link
      end
    end

    if link
      base_link_entry = base_links.find { |name, base_link| link.include?(base_link) }
      if base_link_entry
        social_link_from_profile = base_link_entry.first
        social_links[social_link_from_profile] = ['https://' + link] if !social_links.key?(social_link_from_profile)
      end
    end

    social_links
  end


  def generate_url(user_link)
    "https://www.tiktok.com#{user_link}"
  end
end
