class Profile
  def initialize()
    file = File.open("profile", 'r')
    @raw_data = Array.new
  end
end
