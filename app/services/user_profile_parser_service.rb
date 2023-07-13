class UserProfileParserService

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

    title = extract_title
    subtitle = extract_subtitle
    followers = extract_followers
    bio = extract_bio
    email = extract_email(bio)
    socials = extract_socials(bio)

    user = User.new()
  end

  def extract_title
    #TODO extract title, return string
  end

  def extract_subtitle
    #TODO extract subtitle, return string
  end

  def extract_followers
    #TODO extract followers, return int
  end

  def extract_bio
    #TODO extract bio, return string
  end

  def extract_view_count
    #TODO extract view count on visible videos, get average int and return
  end

  def extract_email(bio)
    #TODO extract email from bio, return string
  end

  def extract_socials(bio)
    #TODO extract all possible socials from bio, return hash {instagram: link}
  end

  def generate_url(user_link)
    "https://www.tiktok.com#{user_link}"
  end
end
