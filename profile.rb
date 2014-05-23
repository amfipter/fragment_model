class Profile
  attr_reader :all_data, :all_answer, :all_answer_s
  def initialize()
    return nil unless File.exists?("profile")
    file = File.open("profile", 'r')
    @raw_data = Array.new
    while(line = file.gets)
      @raw_data.push line.split ' '
    end
    @raw_data.uniq!
    file.close
    @data = Array.new(@raw_data[0].size)
    @all_data = []
    @all_answer = []
    @all_answer_s = Array.new
    parse_input()
    create_answer_d()
    #create_answer_s()
  end

  def parse_input()
    @raw_data[0].size.times do |i|
      print "\rPARSE: #{i + 1}/#{@raw_data[0].size}".blue
      @data[i] = Array.new
      @raw_data.each do |el|
        j = i + @raw_data[0].size
        # puts el[i-2..i+2].to_s
        # puts el.to_s
        # sleep 1/5
        @data[i].push (el+el+el)[j-2..j+2]
      end
    end
    puts " "
    @data.each {|el| @all_data += el}
    @all_data.uniq!
  end

  def create_answer_d()
    puts __method__.to_s.blue
    i=1
    @all_data.each do |el|
      print "\r#{i}/#{@all_data.size}".blue
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
      i += 1
    end
    puts ' '
  end

  def create_answer_s()
    puts __method__.to_s.blue
    i=1
    @all_data.each do |el|
      print "\r#{i}/#{@all_data.size}".blue
      el.map! {|i| i.to_f}
      main_res = $net.eval(el[1..3])
      main = Balancer_tools.vector_extract(main_res)
      left_res = $net.eval(el[0..2])
      left = Balancer_tools.vector_extract(left_res)
      right_res = $net.eval(el[2..4])
      right = Balancer_tools.vector_extract(right_res)
      rule = [0, 0, 0]
      if(main[2] == 1)
        if(left[0] == 1)
          rule[0] = 1
        elsif (right[0] == 1)
          rule[2] = 1
        end
        if(left[1] == 1 and right[1] == 1)
          if (left_res[1] < right_res[1])
            rule[0] = 1
          else
            rule[2] = 1
          end
        end
        if(left[1] == 1 and right[2] == 1)
          rule[0] = 1
        elsif (right[1] == 1 and left[2] == 1)
          rule[2] = 1
        end
      end
      if(rule[0] == 0 and rule[2] == 0)
        rule[1] == 1
      end
      @all_answer_s.push rule
      i += 1
    end
    puts ' '
  end

  def debug_print()
    @all_data.size.times do |i|
      puts @all_data[i].to_s + ' ' + @all_answer[i].to_s
    end

  end

  def rule_simple(input_data)
    output_data = Array.new(3)
    output_data.map! {|i| i = 0}

    if(input_data[1] > $DIFFUSION_THRESHOLD)
      output_data[2] = 1
    elsif (input_data[0] > $DIFFUSION_THRESHOLD or input_data[2] > $DIFFUSION_THRESHOLD)
      output_data[1] = 1
    else
      output_data[0] = 1
    end

    output_data
  end

end
