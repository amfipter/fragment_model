class Feed
  def initialize(seed, type, size, min_diff, max_diff)
    @seed = seed
    @type = type
    @size = size
    @max_diff = max_diff
    @min_diff = min_diff
    @tasks = Array.new
  end

  def simple_gen()
    r = Random.new(@seed)
    @size.times do
      @tasks.push(Work_task.new(r.rand(@min_diff..@max_diff)))
    end
  end

  def get_task()
  	@tasks.pop
  end
end
