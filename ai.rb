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

  def self.create_esoinn_seq()
    net = Esoinn_seq.new()
    net
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
    elsif (input_data[0] > $DIFFUSION_THRESHOLD or input_data[2] > $DIFFUSION_THRESHOLD)
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
  def initialize()
    @esoinn = ESOINN.new
    @prototypes = nil
    @clusters = nil
  end

  def train_all(train_set)
    @esoinn.first_init(train_set.pop, train_set.pop)
    i = 1
    train_set.each do |train|
      print "\r#{i}/#{train_set.size}"
      #puts train.to_s
      @esoinn.new_data(train)
      i += 1
    end
    puts "\nESOINN TRAIN COMPLETE"
    @clusters, @prototypes = @esoinn.classify()
    @prototypes.each do |p|
      puts p.to_s
    end
    puts @clusters
  end

  def predict_next(4vector)
    nil
  end

  def predict_next2(3vector)
    nil
  end

end

class Som_seq()
  nil
end

class Perc_seq()
  nil
end
