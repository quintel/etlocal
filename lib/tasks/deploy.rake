# Tasks used during deployment of the application.
namespace :deploy do
  desc <<-DESC
    Forcefully loads a specific ETSource commit

    rake etsource:load
  DESC
  task load_etsource: :environment do
    binding.pry

    path = Rails.configuration.etsource_path

    cd(path) do
      sh('git fetch origin')
      sh('git reset --hard origin/master')
      sh('git clean -f')
    end

    puts "ETSource #{ real_rev[0..6] } ready at #{ destination }"
  end # load_etsource
end # deploy
