# Tasks used during deployment of the application.
namespace :deploy do
  desc <<-DESC
    Forcefully loads a specific ETSource commit

    rake etsource:load
  DESC
  task load_etsource: :environment do
    cd(Rails.configuration.etsource_path) do
      sh('git fetch origin')
      sh('git reset --hard origin/master')
      sh('git clean -f')
    end
  end # load_etsource
end # deploy
