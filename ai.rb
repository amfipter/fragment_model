module Ai
  def self.create()
    net = Ai4r::NeuralNetwork::Backpropagation.new([3, 24, 22, 3]) #parameters chosen without any reason
    #net = Ai4r::NeuralNetwork::Backpropagation.new([3, 2, 2, 3]) #for test
    net
  end

  def self.create5()
    net = Ai4r::NeuralNetwork::Backpropagation.new([5, 24, 22, 3])
    net
  end

  

  def self.train(net)
    30000.times do
      input, output = Simple_ai_tool.gen()
      net.train(input, output)
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