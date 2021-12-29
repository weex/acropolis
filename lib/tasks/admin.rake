namespace :admin do

  desc "TODO"

  task :create, [:username, :email, :password] => :environment do |_t, args|
    user_params = {username: args[:username], email: args[:email], password: args[:password], password_confirmation: args[:password]}
    user = User.build(user_params)
    user.save!
    Role.add_admin(user)
  end

end
