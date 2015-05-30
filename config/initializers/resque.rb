Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }
Resque.redis = ENV['REDIS_URL'] || 'localhost:6379'
