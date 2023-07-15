class UserProfileParserService
  TITLE_SELECTOR = 'h1[data-e2e="user-title"]'.freeze
  SUBTITLE_SELECTOR = 'h2[data-e2e="user-subtitle"]'.freeze
  FOLLOWERS_COUNT_SELECTOR = 'strong[data-e2e="followers-count"]'.freeze
  BIO_SELECTOR = 'h2[data-e2e="user-bio"]'.freeze
  VIEWS_COUNT_SELECTOR = 'strong[data-e2e="video-views"]'.freeze
  EMAIL_REGEX = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/
  NON_EMAIL_CHAR_SELECTOR = /[^a-zA-Z0-9.@+\-_\s]/
  SOCIALS_SELECTOR = 'a[data-e2e="user-link"] span'.freeze
  HTTPS_ = 'https://'.freeze
  HTTP_ = 'http://'.freeze


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

    return nil unless title

    user = User.find_or_initialize_by(title: title)

    subtitle = extract_subtitle(doc)
    followers_count = extract_followers_count(doc)
    views_on_video = extract_view_count(doc)
    tiktok_link = url
    bio = extract_bio(doc)
    email = extract_email(bio)
    socials = extract_socials(doc, bio)

    user.update(
      subtitle: subtitle,
      followers: followers_count,
      views_on_video: views_on_video,
      bio: bio,
      tiktok_link: tiktok_link,
      email:  email
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
    NumberConversion.human_to_number(human_number)
  end

  def extract_bio(doc)
    element = doc.at_css(BIO_SELECTOR)
    element.text.strip if element
  end

  def extract_view_count(doc)
    elements = doc.css(VIEWS_COUNT_SELECTOR)
    total_views = 0
    elements.each do |element|
      view_count = NumberConversion.human_to_number(element.text.strip)
      total_views += view_count
    end

    average_views = elements.count.positive? ? total_views.to_f / elements.count : 0

    average_views.to_i
  end

  def extract_email(bio)
    clean_bio = bio.gsub(NON_EMAIL_CHAR_SELECTOR, ' ')
    match = clean_bio.match(EMAIL_REGEX)
    match ? match[0] : nil
  end

  def extract_socials(doc, bio)
    element = doc.at_css(SOCIALS_SELECTOR)

    if element
      link = prepend_https(element.text.strip)
    end

    base_links = SocialNetwork.pluck(:name, :base_link).to_h
    social_links = extract_links_from_bio(bio, base_links)

    if link
      base_link_entry = base_links.find { |name, base_link| link.include?(base_link) }
      if base_link_entry
        social_link_from_profile = base_link_entry.first
        social_links[social_link_from_profile] = link unless social_links.key?(social_link_from_profile)
      end
    end

    social_links
  end

  def extract_links_from_bio(bio, base_links)
    base_links.each_with_object({}) do |(name, base_link), links|
      regex = regex_for_link(base_link)
      match = bio.match(regex)

      if match
        links[name] = prepend_https(match[0])
      end
    end
  end

  def prepend_https(link)
    link.start_with?(HTTP_, HTTPS_) ? link : HTTPS_ + link
  end

  def regex_for_link(base_link)
    Regexp.new("(#{HTTP_}|#{HTTPS_})?#{Regexp.escape(base_link)}\\S*", "i")
  end

  def generate_url(user_link)
    "https://www.tiktok.com#{user_link}"
  end
end
