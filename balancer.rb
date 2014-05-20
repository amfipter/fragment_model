class Balancer
  def self.diffusion_simple(lcr_status)
    out = 0
    return out if lcr_status[1] < $DIFFUSION_THRESHOLD
    out = -1 if lcr_status[0] < $DIFFUSION_THRESHOLD
    out = 1 if lcr_status[2] < $DIFFUSION_THRESHOLD
    out
  end
end
