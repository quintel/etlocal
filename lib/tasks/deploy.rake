# frozen_string_literal: true

# Tasks used during deployment of the application.
namespace :deploy do
  desc <<-DESC
    Forcefully loads a specific ETSource commit

    rake etsource:load
  DESC
  task load_etsource: :environment do
    cd(Rails.configuration.etsource_path) do
      if (current_branch = `git rev-parse --abbrev-ref HEAD`.strip) != 'master'
        raise 'Cannot load ETSource: requires that the "master" branch be checked out, but ' \
              "instead found the #{current_branch.inspect} is currently checkout out"
      end

      sh('git fetch origin')
      sh('git reset --hard origin/master')
      sh('git clean -f')
    end
  end # load_etsource
end # deploy
