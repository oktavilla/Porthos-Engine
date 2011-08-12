module PorthosPageTestHelpers
  def stub_index_tank_put
    stub_request(:put, /test\.api\.indextank\.com/).to_return(:status => 200)
  end

  def stub_index_tank_delete
    stub_request(:delete, /test\.api\.indextank\.com/).to_return(:status => 200)
  end
end
