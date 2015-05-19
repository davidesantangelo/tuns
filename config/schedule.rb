every 20.minutes do
  rake "users:unfollowers"
end

every 25.minutes do
  rake "users:lookup"
end
