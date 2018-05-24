# Tasks used during deployment of the application.
namespace :deploy do
  desc <<-DESC
    Forcefully loads a specific ETSource commit

    rake etsource:load
  DESC
  task load_etsource: :environment do
  end # load_etsource
end # deploy
