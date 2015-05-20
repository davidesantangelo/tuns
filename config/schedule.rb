every 5.minutes do
  rake "users:unfollowers"
end

every 5.minutes do
  rake "users:lookup"
end
