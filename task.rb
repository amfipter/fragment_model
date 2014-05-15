class Task
  def initialize()
    nil
  end

end

#class just for tests
class Simple_task
  attr_reader :execute_time, :time_start, :time_end

  def initialize(time)
    @execute_time = time
    @time_start = $time
    @time_end = $time + @execute_time
    nil
  end

  def to_s()
    @execute_time.to_s
  end

  def reinit()
    @time_start = $time
    @time_end = $time + @execute_time
    nil
  end
end

class Method_task < Simple_task
  attr_reader :method_name
  def initialize(time, method_name)
    @execute_time = time
    @method_name = method_name
    @time_start = $time
    @time_end = $time + @execute_time
    nil
  end
end
