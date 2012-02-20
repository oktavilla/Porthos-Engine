module SearchifyStubs
  def stub_searchify_put
    stub_request(:put, /test\.api\.searchify\.com/).to_return(:status => 200)
  end

  def stub_searchify_delete
    stub_request(:delete, /test\.api\.searchify\.com/).to_return(:status => 200)
  end
end
