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

  def self.create_hybrid()
    net = Hybrid_net.new
    net
  end

  def self.train_hybrid(net, input, output)
    net.train_all(input, output)
    nil
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

class Hybrid_net
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
      @esoinn.new_data(train)
      i += 1
    end
    puts "\nESOINN TRAIN COMPLETE"
    @clusters, @prototypes = @esoinn.classify()
    create_perc_set(train_set)

    t1 = 10
    if(@perc_set[0].size > 10)
      t1 = 10 + Math.log2(@perc_set[0].size).to_i
    end
    t2 = (1.5 * t1).to_i
    t3 = t1

    @perc_net = Ai4r::NeuralNetwork::Backpropagation.new([@perc_set[0].size, t1, t2, t3, 3])
    i = 1
    @perc_set.size.times do |i|
      print "\r#{i}/#{@perc_set.size}"
      @perc_net.train(@perc_set[i], answer[i])
    end
    puts "\nPERCEPTRON TRAIN COMPLETE"
    nil
  end

  def create_perc_set(train_set)
    @perc_set = Array.new
    train_set.each do |train|
      v = Array.new
      @prototypes.each do |vector|
        v.push norm(train, vector)
      end
      @perc_set.push v
    end
    nil
  end

  def norm(e1, e2)
    t = 0.0
    e1.size.times do |i|
      t += (e1[i] - e2[i])**2
    end
    t = Math.sqrt(t)
    t
  end

  def eval(vector)
    target_v = Array.new 
    @prototypes.each do |v|
      target_v.push norm(v, vector)
    end
    out = @perc_net.eval(target_v)
    out
  end


end