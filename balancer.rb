class Balancer
  def self.diffusion_simple(lcr_status)
    out = 0
    return out if lcr_status[1] < $DIFFUSION_THRESHOLD
    if(lcr_status[0] < $DIFFUSION_THRESHOLD and lcr_status[2] < $DIFFUSION_THRESHOLD)
      out = -1 if lcr_status[0] < lcr_status[2]
      out = 1 if lcr_status[0] >= lcr_status[2]
      return out
    end
    out = -1 if lcr_status[0] < $DIFFUSION_THRESHOLD
    out = 1 if lcr_status[2] < $DIFFUSION_THRESHOLD
    out
  end

  def self.simple_neuron(llcrr_status, free_l = true, free_r = true)
    main_res = $net.eval(llcrr_status[1..3])
    main = Balancer_tools.vector_extract(main_res)
    left_res = $net.eval(llcrr_status[0..2])
    left = Balancer_tools.vector_extract(left_res)
    right_res = $net.eval(llcrr_status[2..4])
    right = Balancer_tools.vector_extract(right_res)

    if(main[2] == 1)
      if(left[0] == 1 and free_l)
        return -1
      elsif (right[0] == 1 and free_r)
        return 1
      end
      if(left[1] == 1 and right[1] == 1)
        if (left_res[1] < right_res[1] and free_l)
          return -1
        elsif (free_r)
          return 1
        end
      end
      if(left[1] == 1 and right[2] == 1 and free_l)
        return -1
      elsif (right[1] == 1 and left[2] == 1 and free_r)
        return 1
      end
    end
    0
  end

  def self.neuron5(llcrr_status)
    out_res = $net5.eval(llcrr_status)
    res = Balancer_tools.vector_extract(out_res)
    out = -1 if res[0] == 1
    out = 0 if res[1] == 1
    out = 2 if res[2] == 1
    out
  end

  def self.hybrid_esoinn_perc_balance(llcrr_status)
    out_res = $hybrid_net.eval(llcrr_status)
    res = Balancer_tools.vector_extract(out_res)
    out = -1 if res[0] == 1
    out = 0 if res[1] == 1
    out = 2 if res[2] == 1
    out
  end
end



module Balancer_tools
  def self.vector_extract(v)
    m = v.max
    out = Array.new
    v.each do |i|
      out.push 1 if i == m
      out.push 0 if i != m
    end
    out
  end
end
