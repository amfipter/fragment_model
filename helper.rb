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
end
