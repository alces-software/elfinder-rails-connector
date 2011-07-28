require 'dm-rails'

# If you want the logs displayed you have to do this before the call to setup
DataMapper::Logger.new("#{Rails.root}/log/dm.log", :debug)


