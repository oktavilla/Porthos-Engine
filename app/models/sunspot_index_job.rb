class SunspotIndexJob < Struct.new(:model_name, :model_id)
  def perform
    begin
      if m = model_name.constantize.find(model_id)
        Sunspot.index(m)
        Sunspot.commit_if_dirty
      end
    rescue Exception => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
      false
    end
  end
end