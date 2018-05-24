namespace :deploy do
  desc <<-DESC
    Imports a specific revision of ETSource

    Provide the task with an ETSOURCE_REV environment variable whose value is
    a commit reference from the ETSource repository. This commit will be loaded
    on the server. If you choose not to provide an ETSOURCE_REV variable, the
    revision from the currently-running application will be used.

    See etsource:load rake task'
  DESC
  task :etsource do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          `rake deploy:load_etsource`
        end
      end
    end
  end # load_etsource
end # deploy
