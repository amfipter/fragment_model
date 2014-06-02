module Ai
  def self.create()
    net = Ai4r::NeuralNetwork::Backpropagation.new([3, 24, 22, 3]) #parameters chosen without any reason
    #net = Ai4r::NeuralNetwork::Backpropagation.new([3, 2, 2, 3]) #for test
    net
  end

  def self.create5()
    net = Ai4r::NeuralNetwork::Backpropagation.new([5, 10, 10, 3])
    net
  end

  def self.create_som_seq()
    net = Som_seq.new(25)
    net
  end

  def self.create_perc_seq()
    net = Perc_seq.new
    net
  end

  def self.create_esoinn_seq()
    net = Esoinn_seq.new()
    net
  end

  def self.train_perc_seq(net, train_set)
    net.train_all(train_set)
    nil
  end

  def self.train_som_seq(net, train_set)
    net.train_all(train_set)
    nil
  end


  def self.train_esoinn_seq(net, train_set)
    net.train_all(train_set)
    nil
  end


  def self.train5(net, input, output)
    puts "train set: #{input.size}"
    input.size.times do |i|
      net.train(input[i], output[i])
    end
    nil
  end

  def self.train(net)
    30000.times do
      input, output = Simple_ai_tool.gen()
      net.train(input, output)
    end
    nil
  end

  def self.create_hybrid(dim = 5)
    #net = Hybrid_esoinn_net.new
    net = Hybrid_som_net.new(dim)
    net
  end

  def self.train_hybrid(net, input, output)
    net.train_all(input, output)
    nil
  end

  def self.kohonen_test()
    test_samples = [
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 1, 1, 1, 0, 0, 0, 0, 0],
      [1, 1, 1, 1, 1, 0, 0, 0, 0],
      [0, 1, 1, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 1, 1, 0],
      [0, 0, 0, 0, 0, 1, 1, 1, 1],
      [0, 0, 0, 0, 1, 1, 1, 1, 1],
      [0, 0, 0, 0, 0, 1, 1, 1, 0],
      [0, 0, 0, 0, 0, 0, 1, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [1, 1, 1, 1, 0, 0, 0, 0, 0],
      [0, 0, 1, 1, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 1, 1, 0],
      [0, 0, 0, 0, 0, 1, 1, 1, 1]
    ]

    test_data = [
      [0, 1, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 1, 1, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 1, 0, 0],
      [0, 0, 0, 0, 0, 1, 1, 1, 1]
    ]
    num_of_nodes = 4
    som = Ai4r::Som::Som.new(test_samples[0].size, num_of_nodes, Ai4r::Som::TwoPhaseLayer.new(test_samples[0].size * num_of_nodes))
    som.initiate_map

    som.train(test_samples)
    # test_samples.each do |s|
    #   puts s.to_s
    #   som.train(s)
    # end

    puts som.global_error(test_samples)

    test_data.each do |d|
      t = som.find_bmu(d)
      puts t[0].weights.to_s
      puts t[1]
      #puts som.global_error(d)
    end
  end


end

module Simple_ai_tool
  def self.gen()
    input_data = Array.new
    output_data = Array.new(3)
    output_data.map! {|i| i = 0}

    3.times do |i|
      input_data.push Random.rand($TASK_CAPACITY_PER_CORE)
    end

    if(input_data[1] > $DIFFUSION_THRESHOLD)
      output_data[2] = 1
    elsif (input_data[0] > $DIFFUSION_THRESHOLD - 2 or input_data[2] > $DIFFUSION_THRESHOLD - 2)
      output_data[1] = 1
    else
      output_data[0] = 1
    end

    return input_data, output_data
  end
end

class Hybrid_som_net
  def initialize(dim)
    @perc_net = nil
    @som = Ai4r::Som::Som.new(dim, $NUM_OF_NODES, Ai4r::Som::TwoPhaseLayer.new($LAYER_NUM_OF_NODES))
    @som.initiate_map()
    @perc_set = nil
  end

  def train_all(train_set, answer)
    puts train_set.to_s
    puts "SOM TRAIN START".green
    @som.train(train_set)
    puts "SOM TRAIN COMPLETE".green

    create_perc_set(train_set)

    t1 = 10
    if(@perc_set[0].size > 10)
      t1 = 10 + Math.log2(@perc_set[0].size).to_i
    end
    t2 = (1.5 * t1).to_i
    t3 = t1

    @perc_net = Ai4r::NeuralNetwork::Backpropagation.new([@perc_set[0].size, t1, 3])
    @perc_set.size.times do |i|
      print "\r#{i+1}/#{@perc_set.size}".green
      @perc_net.train(@perc_set[i], answer[i])
    end
    nil
  end

  def create_perc_set(train_set)
    @perc_set = Array.new
    train_set.each do |train|
      t = @som.find_bmu(train)
      out = t[0].weights + [t[1]]
      @perc_set.push out
    end
    nil
  end

  def eval(raw_data)
    t = @som.find_bmu(raw_data)
    data = t[0].weights + [t[1]]
    out = @perc_net.eval(data)
    out
  end

end

class Hybrid_esoinn_net
  def initialize()
    @perc_net = nil
    @esoinn = ESOINN.new
    @prototypes = nil
    @clusters = nil
    @perc_set = nil
  end

  def train_all(train_set, answer)
    esoinn_train = train_set.clone
    @esoinn.first_init(esoinn_train.pop, esoinn_train.pop)
    i = 1
    esoinn_train.each do |train|
      print "\r#{i}/#{esoinn_train.size}"
      #puts train.to_s
      @esoinn.new_data(train)
      i += 1
    end
    puts "\nESOINN TRAIN COMPLETE"
    @clusters, @prototypes = @esoinn.classify()
    create_perc_set(train_set)
    puts "CLUSTERS: #{@clusters}".green

    t1 = 10
    if(@perc_set[0].size > 10)
      t1 = 10 + Math.log2(@perc_set[0].size).to_i
    end
    t2 = (1.5 * t1).to_i
    t3 = t1

    @perc_net = Ai4r::NeuralNetwork::Backpropagation.new([@perc_set[0].size, t1, 3])
    i = 1
    1.times do
      @perc_set.size.times do |i|
        print "\r#{i}/#{@perc_set.size}"
        @perc_net.train(@perc_set[i], answer[i])
      end
    end
    puts "\nPERCEPTRON TRAIN COMPLETE"
    nil
  end

  def create_perc_set(train_set)
    @perc_set = Array.new
    train_set.each do |train|
      v = Array.new
      @prototypes.each do |vector|
        v.push norm(train, vector[1])
      end
      # puts v.to_s
      @perc_set.push v
    end
    nil
  end

  def norm(e1, e2)
    t = 0.0
    # puts e1.to_s
    # puts e2.to_s
    e1.size.times do |i|
      t += (e1[i] - e2[i])**2
    end
    t = (Math.sqrt(t)*1).to_i
    t
  end

  def eval(vector)
    target_v = Array.new
    @prototypes.each do |v|
      target_v.push norm(v[1], vector)
    end
    puts target_v.to_s
    out = @perc_net.eval(target_v)
    #puts out
    out
  end
end

class Esoinn_seq
  attr_reader :i1, :i2
  def initialize()
    @esoinn = ESOINN.new
    @prototypes = nil
    @clusters = nil
    @i1 = 0
    @i2 = 0
  end

  def train_all(train_set)
    train_set.shuffle!
    @esoinn.first_init(train_set.pop, train_set.pop)
    puts "TRAIN ESOINN_SEQ".blue
    i = 1
    train_set.each do |train|
      print "\r#{i}/#{train_set.size}".green
      #puts train.to_s
      4.times do |j|
        5.times do |k|
          train[j*5 + k] *= (j+1)
        end
      end
      @esoinn.new_data(train)
      i += 1
    end
    puts "\nESOINN TRAIN COMPLETE"
    @clusters, @prototypes = @esoinn.classify()
    # @prototypes.each do |p|
    #   puts p.to_s
    # end
    puts "ESOINN CLUSTERS: #{@clusters}".red
  end

  #warning!
  def predict_next(vector4)
    vector5 = vector4[0] + vector4[1] + vector4[2] + vector4[3] + [0, 0, 0, 0, 0]
    4.times do |j|
      5.times do |k|
        vector5[j*5 + k] *= (j+1)
      end
    end
    min = $int_max
    min_arr = nil

    @prototypes.each do |proto|
      # puts proto[1].to_s
      # puts vector5.to_s
      # norm = Util.float_norm_vec5(vector5, proto[1])
      norm = Util.norm2(vector5, proto[1])
      if(norm < min)
        min_arr = Array.new
        min = norm
        min_arr.push proto[1]
      elsif(norm == min)
        min_arr.push proto[1]
      end
    end

    if(min_arr.size > 1)
      @i1 += 1
      puts "too many similar vectors!".on_red.bold
    else
      @i2 += 1
    end

    target_v = min_arr.pop
    out = target_v[-5..-1]
    out
  end

  def predict_next2(vector3)
    vector5 = vector3 + [0, 0, 0, 0, 0] + [0, 0, 0, 0, 0]
    nil
  end

end

class Som_seq
  def initialize(dim)
    @som = Ai4r::Som::Som.new(dim, $NUM_OF_NODES, Ai4r::Som::TwoPhaseLayer.new($LAYER_NUM_OF_NODES))
    @som.initiate_map()
  end

  def train_all(train_set)
    # puts train_set[0].to_s
    # puts train_set[-1].to_s
    train_set.each do |train|
      4.times do |j|
        5.times do |k|
          train[j*5 + k] *= (j+1)
        end
      end
    end
    train_set.shuffle!
    puts "SOM TRAIN START".green
    @som.train(train_set)
    puts "SOM TRAIN COMPLETE".green
    nil
  end

  def predict_next(vector4)
    vector5 = vector4[0] + vector4[1] + vector4[2] + vector4[3] + [0, 0, 0, 0, 0]
    4.times do |j|
      5.times do |k|
        vector5[j*5 + k] *= (j+1)
      end
    end
    min = $int_max
    t = @som.find_bmu(vector5)
    target_v = t[0].weights
    out = target_v[-5..-1]
    out
  end

  def predict_next2(vector3)
    vector5 = vector3 + [0, 0, 0, 0, 0] + [0, 0, 0, 0, 0]
    nil
  end
end

class Perc_seq
  def initialize()
    @perc_net = Ai4r::NeuralNetwork::Backpropagation.new([20, 10, 5, 3])
    @perc_set = nil
  end

  def train_all(train_set)
    puts "TRAIN PERC_SEQ".blue
    train_set.shuffle!
    l = 0
    c = 0
    r = 0
    5.times do
      train_set.each do |train|
        train_part = train[0..19]
        #answer = Util.load_state(train[20..24])
        answer_d = Util.predict_direction(train[20..24])
        answer = [0, 0, 0]
        answer[answer_d + 1] = 1
        l += 1 if answer[0] == 1
        c += 1 if answer[1] == 1
        r += 1 if answer[2] == 1
        #puts train[20..24].to_s + ' ' + answer.to_s
        @perc_net.train(train_part, answer)
      end
    end
    # puts ''
    # puts l
    # puts c
    # puts r
    nil
  end

  def predict_next_state(vector4)
    out_raw = @perc_net.eval(vector4[0] + vector4[1] + vector4[2] + vector4[3])
    out_raw
  end
end
