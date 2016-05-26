# config valid only for current version of Capistrano
lock '3.3.4'

set :repo_url, 'git@github.com:SuperbCoders/dynamica2.git'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/shopify.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads', 'public/report_images')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  task :clear_assets do
    on roles(:web) do
      within release_path do
        execute :rake, "assets:clean"
        execute :rake, "assets:clobber"
      end
    end
  end

  task :restart do
    invoke 'unicorn:restart'
  end

  task :seed do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        # execute :bundle, "exec rake db:seed RAILS_ENV=#{fetch(:stage)}"
      end
    end
  end
end

namespace :bower do
  desc 'Install bower'
  task :install do
    on roles(:web) do
      within release_path do
        execute :rake, "bower:install['-f']"
      end
    end
  end
end

after 'deploy:publishing', 'deploy:restart'
# after 'deploy:updated', 'deploy:seed'
before 'deploy:compile_assets', 'bower:install'
