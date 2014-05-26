module Util
  def self.norm2(v1, v2)
    out = 0.0
    v1.size.times do |i|
      out += (v1[i] - v2[i])**2
    end
    out = Math.sqrt(out)
    out
  end

  def self.norm_i(v1, v2, i)
    out = 0.0
    v1.size.times do |j|
      out += (v1[j] - v2[j])**i
    end
    out = Math.sqrt(out)
    out
  end

  def self.float_norm_vec5(v1, v2)
    out = 0.0
    (v1.size/5).times do |i|
      out += norm_i(v1[i*5..(i*5 + 4)], v2[i*5..(i*5 + 4)], i+1)
    end
    out
  end

  def self.load_state(llcrr_status)
    out = [0.0, 0.0, 0.0]
    if(llcrr_status[2] > $DIFFUSION_THRESHOLD)
      out[2] = 1.0
      return out
    end

    if(llcrr_status[1] > $DIFFUSION_THRESHOLD or llcrr_status[3] > $DIFFUSION_THRESHOLD)
      out[2] = 0.5
      out[1] = 0.5
      return out
    end

    if(llcrr_status[0] > $DIFFUSION_THRESHOLD or llcrr_status[4] > $DIFFUSION_THRESHOLD)
      out[1] = 1
      return out
    end

    out[0] = 1
    out
  end

  def self.predict_direction(llcrr_status)
    left = Math.sqrt(
      llcrr_status[0].to_f**2 +
      llcrr_status[1].to_f**2 +
      llcrr_status[2].to_f**2
    )
    center = Math.sqrt(
      llcrr_status[1].to_f**2 +
      llcrr_status[2].to_f**2 +
      llcrr_status[3].to_f**2
    )
    right = Math.sqrt(
      llcrr_status[2].to_f**2 +
      llcrr_status[3].to_f**2 +
      llcrr_status[4].to_f**2
    )
    out = Balancer_tools.simple_solution(left, center, right)
    out
  end

  def self.serialization_save(data, file_name)
    return nil if data.nil?
    File.open(file_name, 'w') do |file|
      Marshal.dump(data, file)
    end
  end

  def self.serialization_load(file_name)
    data = nil
    if(File.exists?(file_name))
      File.open(file_name) do |file|
        data = Marshal.load(file)
      end
    end
    data
  end

  def self.net_init()
    if($net.nil?)
      $net = Ai.create()
      Ai.train($net)
    end

    if($net5.nil?)
      $net5 = Ai.create5()
      Ai.train5($net5, $profile.all_data, $profile.all_answer)
    end

    if($hybrid_net.nil?)
      $hybrid_net = Ai.create_hybrid()
      Ai.train_hybrid($hybrid_net,
                      $profile.all_data,
                      $profile.all_answer_s
                      )
    end

    if($esoinn_prediction_net.nil?)
      $esoinn_prediction_net = Ai.create_esoinn_seq()
      Ai.train_esoinn_seq($esoinn_prediction_net,
                          $profile.all_data_seq_s
                          )
    end

    if($som_prediction_net.nil?)
      $som_prediction_net = Ai.create_som_seq()
      Ai.train_som_seq($som_prediction_net,
                       $profile.all_data_seq_s
                       )
    end

    if($perc_prediction_net.nil?)
      $perc_prediction_net = Ai.create_perc_seq()
      Ai.train_perc_seq($perc_prediction_net,
                        $profile.all_data_seq_s
                        )
    end
  end

end
