class UserProfileParserService

  def initialize(links)
    @links = links
  end

  def call
    @links.map do |link|
      process_profile(link)
    end
  end

  private

  def process_profile(link)

  end

  def extract_profile_data(doc)

  end

  def generate_link

  end
end
