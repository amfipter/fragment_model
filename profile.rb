class Profile
  attr_reader :all_data, :all_answer
  def initialize()
    return nil unless File.exists?("profile")
    file = File.open("profile", 'r')
    @raw_data = Array.new
    while(line = file.gets)
      @raw_data.push line.split ' '
    end
    file.close
    @data = Array.new(@raw_data[0].size)
    @all_data = []
    @all_answer = []
    parse_input()
    create_answer_d()
  end

  def parse_input()
    @raw_data[0].size.times do |i|
      @data[i] = Array.new
      @raw_data.each do |el|
        j = i + @raw_data[0].size
        # puts el[i-2..i+2].to_s
        # puts el.to_s
        # sleep 1/5
        @data[i].push (el+el+el)[j-2..j+2]
      end
    end
    @data.each {|el| @all_data += el}
  end

  def create_answer_d()
    @all_data.uniq!
    @all_data.each do |el|
      el.map! {|i| i.to_f}
      l = Math.sqrt(el[0]**2 + el[1]**2 + el[2]**2)
      c = Math.sqrt(el[1]**2 + el[2]**2 + el[3]**2)
      r = Math.sqrt(el[2]**2 + el[3]**2 + el[4]**2)
      out = nil
      case [l,c,r].min
      when l
        out = [1, 0, 0]
      when c
        out = [0, 1, 0]
      when r
        out = [0, 0, 1]
      end
      @all_answer.push out
    end
  end

  def debug_print()
    @all_data.size.times do |i|
      puts @all_data[i].to_s + ' ' + @all_answer[i].to_s
    end

  end

end
