class Setting < ActiveRecord::Base
  belongs_to :settingable, :polymorphic => true
  
end