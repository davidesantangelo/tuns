job_type :rake_with_lock, "cd :path && export :environment_variable=:environment && /usr/bin/flock -n /tmp/:task.lock bundle exec rake :task --silent :output"

env :MAILTO, 'davide.santangelo@gmail.com'
env :PATH, ENV['PATH']

every 8.hours do
  rake_with_lock "users:unfollowers"
end
