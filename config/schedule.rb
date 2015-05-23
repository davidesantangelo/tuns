every 15.minutes do
  rake "users:unfollowers"
end

every 10.minutes do
  rake "users:lookup"
end
