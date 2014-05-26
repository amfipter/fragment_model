class Timeline
  def initialize()
    @time = Hash.new
    @time_keys_cache = []
  end

  def add_event(task)
    time = $time
    unless(@time_keys_cache[-1].nil?)
      time = @time_keys_cache[-1]
    end
    puts task.to_f if $debug
    task.reinit(time)
    @time[time] = task
    update_cache()
    nil
  end

  def get_time()
    return @time_keys_cache[0] unless @time_keys_cache[0].nil?
    $int_max
  end

  def size()
    @time.size
  end
  

  #get nearest task and remove it from task queue
  def get_task!()
    task = @time[@time_keys_cache[0]]
    @time.delete(@time_keys_cache[0])
    update_cache()
    task
  end

  def update_cache()
    @time_keys_cache = @time.keys.sort
    nil
  end

  def can_get_task?()
    i=0
    @time.each do |el|
      i+= 1 if el.class.eql? Task
    end
    return true if i < $TASK_PER_CORE
    false
  end

  def have_feed_task?()
    out = false
    @time.values.each do |task|
      if(task.class.eql? Method_task)
        out = true if task.method_name.eql? "feed"
      end
    end
    out
  end

  def have_lcr_update_task?()
    out = false
    @time.values.each do |task|
      if(task.class.eql? Method_task)
        out = true if task.method_name.eql? "lcr_update"
      end
    end
    out
  end

  def have_llcrr_update_task?()
    out = false
    @time.values.each do |task|
      if(task.class.eql? Method_task)
        out = true if task.method_name.eql? "llcrr_update"
      end
    end
    out
  end

  def have_balance_task?()
    out = false
    @time.values.each do |task|
      if(task.class.eql? Method_task)
        out = true if task.method_name.eql? "balance"
      end
    end
    out
  end


  # def get_time!()
  #   @time.shift
  # end

  # def rm_time()
  #   @time.shift
  #   nil
  # end

end
