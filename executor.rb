class Executor
  def initialize(cores_count = $cores_size)
    @cores = Array.new
    @tasks = Array.new
    cores_count.times {|i| @cores.push Core.new(i)}
    nil
  end

  def start()
    nil
  end

  def start_simple()
    while(true) do
      #puts @tasks.size
      check_cores_state_simple()
      nearest = $int_max
      target_core = nil
      @cores.each do |core|
        #puts core.tasks.size
        t = core.get_time_simple()
        #puts t
        if(t < nearest)
          nearest = t
          target_core = core
        end
      end
      if(nearest == $int_max)
        return nil
      end
      puts "#{$time} #{nearest}"
      #nearest -= $time
      $time = nearest
      target_core.execute_simple()
    end
    nil
  end

  def print_result_simple()
    @cores.each do |core|
      puts "ID: #{core.id}     TIME:#{core.log_time}"
    end
  end

  def check_cores_state_simple()
    return nil if @tasks.size == 0
    @cores.each do |core|
      if(core.tasks.size == 0)
        core.tasks.push @tasks.pop
      end
    end
    nil
  end

  def init_simple()
    $task_count.times do 
      @tasks.push Simple_task.new(Random.rand(10..1000))
    end

    #debug_task_print()

    @cores.each do |core|
      core.tasks.push @tasks.pop
      core.init_timeline_simple()
    end
  end

  def debug_task_print()
    @tasks.each do |task|
      puts task.to_s
    end
    nil
  end

end