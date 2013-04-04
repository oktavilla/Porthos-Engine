class ParamsCacheKey
  def self.key params
    Digest::MD5.hexdigest params.sort.join("-")
  end
end
