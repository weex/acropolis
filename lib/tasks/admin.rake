require 'tty-prompt'

namespace :admin do

  task :create, [:username, :email, :password] => [:environment] do |task, args|

    puts"********** testinggggg ***********"

    # user_params = {username: args[:username], email: args[:email], password: args[:password], password_confirmation: args[:password]}
    # user = User.build(user_params)
    # user.save!
    # Role.add_admin(user)

    # prompt = TTY::Prompt.new
    # begin
    #   if prompt.yes?('Do you want to create an admin user straight away?')   
    #     loop do
    #       username = prompt.ask('Username:') do |q|
    #         q.required true
    #         q.validate(/\A[a-z0-9_]+\z/i)
    #         q.modify :strip
    #       end
    #       email = prompt.ask('E-mail:') do |q|
    #         q.required true
    #         q.modify :strip
    #       end
    #       password = SecureRandom.hex(16)
    #       user_params = {username: username, email: email, password: password, password_confirmation: password}
    #       user = User.build(user_params)
    #       begin
    #         user.save!
    #         Role.add_admin(user)
    #         prompt.ok 'Admin user created successfully! 🎆'
    #         prompt.ok "You can login with the password: #{password}"
    #         prompt.warn 'You can change your password once you login.'
    #         break
    #       rescue StandardError => e
    #         prompt.error e.message
    #         break unless prompt.yes?('Try again?')
    #       end
    #     end
    #   else
    #     prompt.warn 'Nothing saved. Bye!'
    #   end
    # rescue TTY::Reader::InputInterrupt
    #   prompt.ok 'Aborting. Bye!'
    # end
  end
  
end