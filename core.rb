class Core
  attr_accessor :tasks, :log_time, :id, :count, :active

  def initialize(id, active = false)
    @id = id
    @active = active
    @timelines = Array.new
    @tasks = Array.new
    @running_tasks = Array.new
    @timelines.push Timeline.new
    @free_time = nil
    @log_time = 0
    @count = 0
    @lcr_new = false

    @data_timeline = Timeline.new
    @transfer_timeline = Timeline.new
    @service_timeline = Timeline.new
    @lcr_status = [0, 0, 0]                #left-right state of cores. Diffusion balance
    @llcrr_status = [0, 0, 0, 0, 0]              #left-left-center-right-right state. Neuron balance
    @vector4_llcrr_status = Array.new
    nil
  end

  def empty?()
    return true if (@tasks.size == 0 and !running_data_task?() and @data_timeline.size == 0)
    false
  end

  def init()
    if (active)
      $TASK_CAPACITY_PER_CORE.times do
        if($feed.task?)
          @tasks.push $feed.get_task()
        end
      end
    end
    planning()
  end

  def feed()
    puts "feed" if $debug
    if (active)
      ($TASK_CAPACITY_PER_CORE - @tasks.size).times do
        if($feed.task?)
          @tasks.push $feed.get_task
        end
      end
    end
  end

  def accept_transfer(task)
    @transfer_timeline.add_event(task)
    nil
  end

  def create_transfer(target_diff)
    package = Array.new
    $TRANSFER_PACKAGE_CAPACITY.times do
      t = @tasks.pop
      package.push t unless t.nil?
    end
    task = Transfer_task.new(1, package)
    $comm.send_task_package(@id, target_diff, task)
  end

  def gen_lcr_update_task()
    puts "gen_lcr_update_task" if $debug
    task = Method_task.new($LCR_STATUS_REQUEST_TIME, "lcr_update")
    puts task.to_f if $debug
    task
  end

  def gen_llcrr_update_task()
    puts "gen_llcrr_update_task" if $debug
    task = Method_task.new($LLCRR_STATUS_REQUEST_TIME, "llcrr_update")
    task
  end

  def gen_feed_task()
    puts "gen_feed_task" if $debug
    task = Method_task.new($FEED_REQEST_TIME, "feed")
    task
  end

  def gen_balance_task()
    puts "gen_balance_task" if $debug
    task = Method_task.new($DIFFUSION_BALANCE_TIME, "balance") if $DIFFUSION_BALANCE
    task = Method_task.new($NEURON_PERC_BALANCE_TIME, "balance") if $SIMPLE_NEURON_BALANCE
    task = Method_task.new($NEURON_PERC_BALANCE_TIME, "balance") if $NEURON5_BALANCE
    task = Method_task.new($NEURON_PERC_BALANCE_TIME, "balance") if $HYBRID_NEURON_BALANCE
    task = Method_task.new($NEURON_PERC_BALANCE_TIME, "balance") if $ESOINN_PREDICTION_BALANCE
    task = Method_task.new($NEURON_PERC_BALANCE_TIME, "balance") if $SOM_PREDICTION_BALANCE
    task = Method_task.new($NEURON_PERC_BALANCE_TIME, "balance") if $PERC_PREDICTION_BALANCE
    task = Method_task.new($NEURON_PERC_BALANCE_TIME, "balance") if $HYBRID_PREDICTION_BALANCE
    task
  end

  def balance()
    #puts "balance" #if $debug
    diffusion_balance() if $DIFFUSION_BALANCE
    simple_neuron_balance() if $SIMPLE_NEURON_BALANCE
    neuron5_balance() if $NEURON5_BALANCE
    hybrid_esoinn_perc_balance() if $HYBRID_NEURON_BALANCE
    esoinn_prediction_balance() if $ESOINN_PREDICTION_BALANCE
    som_prediction_balance() if $SOM_PREDICTION_BALANCE
    perc_prediction_balance() if $PERC_PREDICTION_BALANCE
    hybrid_prediction_balance() if $HYBRID_PREDICTION_BALANCE
    nil
  end

  def diffusion_balance()
    advice = Balancer.diffusion_simple(@lcr_status)
    #puts advice
    #puts @lcr_status.to_s
    #return nil unless @lcr_new
    return nil if advice == 0
    create_transfer(advice)
    @lcr_new = false
    nil
  end

  def simple_neuron_balance()
    advice = Balancer.simple_neuron(@llcrr_status)
    return nil if advice == 0
    create_transfer(advice)
    nil
  end

  def neuron5_balance()
    advice = Balancer.neuron5(@llcrr_status)
    return nil if advice == 0
    create_transfer(advice)
    nil
  end

  def hybrid_esoinn_perc_balance()
    advice = Balancer.hybrid_esoinn_perc_balance(@llcrr_status)
    #puts advice #if advice > -1
    return nil if advice == 0
    create_transfer(advice)
    nil
  end

  def esoinn_prediction_balance()
    if (@vector4_llcrr_status.size == 4)
      advice, @predict = Balancer.esoinn_prediction_balance(@vector4_llcrr_status)
    end
    return nil if advice == 0 or advice.nil?
    create_transfer(advice)
    nil
  end

  def som_prediction_balance()
    advice, @predict = Balancer.som_prediction_balance(@vector4_llcrr_status) if @vector4_llcrr_status.size == 4
    return nil if advice == 0 or advice.nil?
    create_transfer(advice)
    nil
  end

  def perc_prediction_balance()
    advice = Balancer.perc_prediction_balance(@vector4_llcrr_status) if @vector4_llcrr_status.size == 4
    return nil if advice == 0 or advice.nil?
    create_transfer(advice)
    nil
  end

  def hybrid_prediction_balance()
    advice = Balancer.hybrid_prediction_next_balance(@vector4_llcrr_status, @llcrr_status)
    return nil if advice == 0 or advice.nil?
    create_transfer(advice)
    nil
  end

  def get_time()
    transfer = @transfer_timeline.get_time()
    service = @service_timeline.get_time()
    data = @data_timeline.get_time()
    running_tasks_time = [$int_max]
    @running_tasks.each {|task| running_tasks_time.push task.time_end}
    [transfer, service, data, running_tasks_time.min].min
  end

  def exec()
    puts "exec" if $debug
    if(time_to_start_job?())
      puts "start job" if $debug
      case $time
      when @transfer_timeline.get_time()
        exec_transfer()
      when @service_timeline.get_time()
        exec_service()
      when @data_timeline.get_time()
        exec_data()
      end
    else
      @running_tasks.each do |task|
        if(task.time_end == $time)
          complete_task(task)
          @running_tasks.delete task
        end
      end
    end

    planning()

  end

  def planning()
    puts "planning" if $debug
    unless(@service_timeline.have_feed_task?() or running_feed_task?())
      @service_timeline.add_event(gen_feed_task())
    end

    unless(@service_timeline.have_balance_task?() or running_balance_task?())
      @service_timeline.add_event(gen_balance_task())
    end

    unless(@service_timeline.have_lcr_update_task?() or running_lcr_update_task?())
      @service_timeline.add_event(gen_lcr_update_task())
    end

    unless(@service_timeline.have_llcrr_update_task?() or running_llcrr_update_task?())
      @service_timeline.add_event(gen_llcrr_update_task())
    end

    if(@data_timeline.size < $CORE_TASK_BUFFER)
      @data_timeline.add_event(@tasks.pop) if (@tasks.size > 0 and !running_data_task?() and @tasks.size > 0)
    end
  end


  def complete_task(task)
    puts "complete_task" if $debug
    case task
    when Work_task
      complete_data_task(task)
    when Transfer_task
      complete_transfer_task(task)
    when Method_task
      complete_service_task(task)
    end
  end

  def complete_transfer_task(task)
    puts "complete_transfer_task" if $debug
    data = task.tasks
    @tasks += data
    nil
  end

  def complete_service_task(task)
    puts "complete_service_task" if $debug
    case task.method_name
    when "feed"
      feed()
    when "balance"
      balance()
    when "lcr_update"
      lcr_status_update()
    when "llcrr_update"
      llcrr_status_update()
    end
  end

  def complete_data_task(task)
    #puts "complete_data_task" if $debug
    @log_time += task.execute_time
    @count += 1
    #puts "exec #{@id} time: #{task.execute_time}"
    nil
  end

  def exec_transfer()
    puts "exec_transfer" if $debug
    task = @transfer_timeline.get_task!()
    @running_tasks.push task
    nil
  end

  def exec_service()
    puts "exec_service" if $debug
    task = @service_timeline.get_task!()
    @running_tasks.push task
    nil
  end

  def exec_data()
    puts "exec_data" if $debug
    task = @data_timeline.get_task!()
    @running_tasks.push task
    nil
  end

  def lcr_status_update()
    puts "lcr_status_update" if $debug
    @lcr_status = $comm.lcr_status(@id)
    @lcr_new = true
    nil
  end

  def llcrr_status_update()
    puts "llcrr_status_update" if $debug
    last = @llcrr_status
    @llcrr_status = $comm.llcrr_status(@id)
    unless(@predict.nil?)
      puts @predict.to_s
      puts last.to_s
      puts @llcrr_status.to_s
      puts @vector4_llcrr_status.to_s
      @predict = nil
    end
    unless(last == @llcrr_status)
      @vector4_llcrr_status.push @llcrr_status
      @vector4_llcrr_status.pop if @vector4_llcrr_status.size > 4
    end

    nil
  end

  #initialize timeline (consequences of passive execution)
  def init_timeline_simple()
    unless @tasks.size == 0
      #puts "init"
      @timelines[0].add_event(@tasks.pop)
    end
    nil
  end

  #get nearest time from timeline
  def get_time_simple()
    unless(@free_time.nil?)
      return @free_time
    else
      return @timelines[0].get_time()
    end
  end



  def execute_simple()
    #puts "exec"
    unless(@free_time.nil?)
      planning_simple()
      return nil
    end
    @count += 1
    task = @timelines[0].get_task!()
    @log_time += task.execute_time
    puts "exec #{@id} time: #{task.execute_time}"
    @free_time = $time + task.execute_time
    nil
  end

  #set new task to timeline queue
  def planning_simple()
    @free_time = nil
    if(@tasks.size > 0)
      # @timelines[0].add_event(Simple_task.new(2))
      # $time += 1
      @timelines[0].add_event(@tasks.pop)
    end
    nil
  end

  def time_to_start_job?()
    transfer = @transfer_timeline.get_time()
    service = @service_timeline.get_time()
    data = @data_timeline.get_time()
    return true if [transfer, service, data].min == $time
    false
  end

  def running_feed_task?()
    out = false
    @running_tasks.each do |task|
      if(task.class.eql? Method_task and task.method_name.eql? "feed")
        out = true
      end
    end
    out
  end

  def running_balance_task?()
    out = false
    @running_tasks.each do |task|
      if(task.class.eql? Method_task and task.method_name.eql? "balance")
        out = true
      end
    end
    out
  end

  def running_lcr_update_task?()
    out = false
    @running_tasks.each do |task|
      if(task.class.eql? Method_task and task.method_name.eql? "lcr_update")
        out = true
      end
    end
    out
  end

  def running_llcrr_update_task?()
    out = false
    @running_tasks.each do |task|
      if(task.class.eql? Method_task and task.method_name.eql? "llcrr_update")
        out = true
      end
    end
    out
  end

  def running_data_task?()
    out = false
    @running_tasks.each do |task|
      if(task.class.eql? Work_task)
        out = true
      end
    end
    out
  end




end
