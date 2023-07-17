class UserProfileUpdaterService
  def initialize(user_link)
    @parsed_data = ProfilePageParserService.new(user_link).call
  end

  def call
    return if @parsed_data[:title].nil?

    user = User.find_or_initialize_by(title: @parsed_data[:title])

    user.update(
      subtitle: @parsed_data[:subtitle],
      followers: @parsed_data[:followers_count],
      views_on_video: @parsed_data[:views_on_video],
      bio: @parsed_data[:bio],
      tiktok_link: @parsed_data[:tiktok_link],
      email:  @parsed_data[:email]
    )

    update_socials(user)

    user
  end

  private

  def update_socials(user)
    @parsed_data[:socials].each do |name, url|
      social_network = SocialNetwork.find_by(name: name)
      user_social = UserSocial.find_or_initialize_by(user: user, social_network: social_network)
      user_social.update(url: url)
    end
  end
end
