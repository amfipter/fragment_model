class Executor
  def initialize(cores_count, task_count)
    @cores = Array.new
    @tasks = nil
    $feed = Feed.new(100500, nil, task_count, $MIN_TASK_DIFF, $MAX_TASK_DIFF)
    cores_count.times {|i| @cores.push Core.new(i)}
    set_active_cores()
    $comm = Comm.new(@cores)
    @profile = Array.new
    @last = Array.new
    nil
  end

  def start()
    #puts $feed.task?
    puts "executor".upcase.red
    @cores.each {|core| core.init()}
    while(true) do 
      #cores_debug_print()
      print "\r#{$task_count-$feed.size}/#{$task_count}".green
      nearest = $int_max
      target_core = nil
      @cores.each do |core|
        t = core.get_time()
        if(t<nearest)
          nearest = t
          target_core = core
        end
      end
      if(nearest == $int_max)
        # return nil
      end
      #puts "#{$time} #{nearest}"
      $time = nearest
      target_core.exec()
      work = false
      @cores.each {|core| work = true unless core.empty?()}
      work = true if $feed.size > 0
      unless(work)
        # c = 0
        # @cores.each {|core| c += core.count}
        # puts c
        break

      end
      $comm.update()
      capture_profile()
      #sleep 1/5
    end
    puts "\r#{$task_count}/#{$task_count}".red
    write_profile() if $WRITE_PROFILE
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
      all_task = 0
      @cores.each do |core|
        all_task += core.count
        #puts "ID: #{core.id}     TIME:#{core.log_time} COUNT:#{core.count}".light_blue
        puts core.count 
      end
      puts "ALL TASK: #{all_task}".blue
    end

    def check_cores_state_simple()
      return nil if @tasks.size == 0
      @cores.each do |core|
        if(core.tasks.size == 0)
          #core.tasks.push Simple_task.new(2)
          core.tasks.push @tasks.pop
        end
      end
      nil
    end

    def init_simple()
      random = Random.new(100500)
      $task_count.times do
        @tasks.push Simple_task.new(random.rand(100..1000))
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

    def cores_debug_print()
      @cores.each do |core|
        puts "core id: #{core.id}\tactive:#{core.active}"
        puts "core tasks: #{core.tasks.size}"
      end
      nil
    end

    def set_active_cores()
      @cores[$cores_count/2].active = true
      nil
    end

    def capture_profile()
      current = Array.new
      @cores.each {|core| current.push core.tasks.size}
      return nil if current.eql? @last
      @profile.push current
      @last = current
    end

    def write_profile()
      f = File.new("profile", "w")
      @profile.each do |line|
        f.puts line.join ' '
      end
      f.close
    end

end
