class Timeline
  def initialize()
    @time = Hash.new
    @time_keys_cache = nil
  end

  def add_event(task)
    task.reinit
    @time[$time] = task
    update_cache()
    nil
  end

  def get_time()
    return @time_keys_cache[0] unless @time_keys_cache[0].nil?
    $int_max
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


  # def get_time!()
  #   @time.shift
  # end

  # def rm_time()
  #   @time.shift
  #   nil
  # end

end
