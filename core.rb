class Core
  attr_accessor :tasks, :log_time, :id, :count

  def initialize(id, active = false)
    @id = id
    @active = active
    @timelines = Array.new
    @tasks = Array.new
    @timelines.push Timeline.new
    @free_time = nil
    @log_time = 0
    @count = 0
    nil
  end

  # def get_time()
  #   time = -1
  #   time = @main_time.get_time() unless @main_time.get_time().nil?
  #   t = @balance_time.get_time() unless @balance_time.get_time().nil?
  #   time = t if t < time
  #   time
  # end

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



  
end