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
    #puts llcrr_status.to_s
    out_res = $hybrid_net.eval(llcrr_status)
    #puts out_res.to_s
    res = Balancer_tools.vector_extract(out_res)
    out = -1 if res[0] == 1
    out = 0 if res[1] == 1
    out = 1 if res[2] == 1
    out
  end

  def self.esoinn_prediction_balance(vector4_llcrr_status)
    predict_llcrr_status = $esoinn_prediction_net.predict_next(vector4_llcrr_status)
    left = Math.sqrt(
      predict_llcrr_status[0].to_f**2 +
      predict_llcrr_status[1].to_f**2 +
      predict_llcrr_status[2].to_f**2
    )
    center = Math.sqrt(
      predict_llcrr_status[1].to_f**2 +
      predict_llcrr_status[2].to_f**2 +
      predict_llcrr_status[3].to_f**2
    )
    right = Math.sqrt(
      predict_llcrr_status[2].to_f**2 +
      predict_llcrr_status[3].to_f**2 +
      predict_llcrr_status[4].to_f**2
    )
    if(center < left and center < right)
      return 0
    end

    if(center > left and center < right)
      return -1
    end

    if(center < left and center > right)
      return 1
    end

    if(left > right)
      return 1
    else
      return -1
    end
    nil
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
