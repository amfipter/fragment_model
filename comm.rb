class Comm
  def initialize(cores)
    @cores = cores
    @cores_count = cores.size
    @data = Hash.new
  end

  def update()
    @cores.each do |core|
      @data[core.id] = core.tasks.size
    end
    nil
  end

  def llcrr_status(id)
  	ll = @data[(id-2) % @cores_count]
  	l = @data[(id-1) % @cores_count]
  	c = @data[id]
  	r = @data[(id+1) % @cores_count]
  	rr = @data[(id+2) % @cores_count]
  	out = [ll, l, c, r, rr]
  	out
  end
end
