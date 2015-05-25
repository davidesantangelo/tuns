# app/workers/delete_user_worker.rb
class DeleteUserWorker
  include Sidekiq::Worker

  def perform(user_id)
  	User.find(user_id).destroy
  end
end