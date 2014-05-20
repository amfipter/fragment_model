class Feed
  def initialize(seed, type, size, min_diff, max_diff)
    @seed = seed
    @type = type
    @size = size
    @max_diff = max_diff
    @min_diff = min_diff
    @tasks = Array.new
    simple_gen()
  end

  def simple_gen()
    r = Random.new(@seed)
    @size.times do
      @tasks.push(Work_task.new(@min_diff + r.rand(@max_diff-@min_diff)))
    end
  end

  def get_task()
  	@tasks.pop
  end

  def task?()
  	return true if @tasks.size > 0
  	false
  end
end
