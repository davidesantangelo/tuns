class Request < ActiveRecord::Base
	belongs_to :user
	enum resource:  {  "application" => 0, "favorites" => 1, "followers" => 2, 
									   "friends" => 3, "friendships" => 4, "help" => 5, "lists" => 6,
									   "search" => 7, "statuses" => 8, "trends" => 9, "users" => 10
									}
end
