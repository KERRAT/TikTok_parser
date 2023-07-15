class NumberConversion
  def self.human_to_number(human)
    return human unless human.is_a? String
    return human if human.blank?
    human.downcase!
    if human.index('k') || human.index('thousand')
      multiplier = 1000
    elsif human.index('m')
      multiplier = 1_000_000
    elsif human.index('b')
      multiplier = 1_000_000_000
    elsif human.index('t')
      multiplier = 1_000_000_000_000
    else
      multiplier = 1
    end
    number = human.gsub(/[^0-9\.]/,'').to_f
    number * multiplier
  end
end
