require 'mina/git'
require 'mina/bundler'
require 'mina/rbenv'


set :domain, ENV['domain'] || 'example.com'
set :repository, 'git@git.example.com:user/repo'
set :branch, 'master'
set :user, 'USERNAME'
set :deploy_to, '/home/USERNAME/app'
set :shared_paths, [ 'tmp' ]
set :term_mode, :pretty


task :environment do
  invoke :'rbenv:load'
  invoke :'nvm:load'
end


task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/tmp"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp"]

  task :server do
    invoke :'setup:install_node'
    invoke :'setup:install_ruby'
  end

  task :install_node do
    queue 'curl https://raw.github.com/creationix/nvm/master/install.sh | sh'
    queue %{
      export LC_ALL=C LANG=C MANPATH=`manpath`
      source ~/.nvm/nvm.sh
      nvm install 0.10.26
      nvm alias default 0.10
    }
  end

  task :install_ruby do
    queue 'test -d ~/.rbenv || git clone https://github.com/sstephenson/rbenv.git ~/.rbenv'
    queue 'test -d ~/.rbenv/plugins/ruby-build || git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build'
    invoke :'rbenv:load'
    queue 'rbenv install 2.1.1'
    queue 'rbenv global 2.1.1'
    queue 'gem install bundler'
  end
end

desc "Deploys the current version and restarts the nodejs server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'npm:install'
    invoke :'process:build'
    invoke :'process:test'
    to :launch do
      invoke :'process:restart'
    end
  end
end

task :'nvm:load' do
  queue 'echo "-----> Loading nvm"'
  queue %{
    #{echo_cmd %{source ~/.nvm/nvm.sh}}
  }
end

task :'npm:install' do
  queue 'npm install'
end

namespace :process do
  task :build => :environment do
    queue 'echo "-----> Build assets."'
    queue %{
      cd #{deploy_to!}/#{current_path!}
      make build
    }
  end

  task :test => :environment do
    queue 'echo "-----> Test server."'
    queue %{
      cd #{deploy_to!}/#{current_path!}
      make test
    }
  end

  task :start => :environment do
    queue 'echo "-----> Start server."'
    queue %{
      cd #{deploy_to!}/#{current_path!}
      make start
    }
  end

  task :stop => :environment do
    queue 'echo "-----> Stop server."'
    queue %{
      cd #{deploy_to!}/#{current_path!}
      make stop
    }
  end

  task :restart => :environment do
    queue 'echo "-----> Restart server."'
    queue %{
      cd #{deploy_to!}/#{current_path!}
      make restart
    }
  end

  task :reload => :environment do
    queue 'echo "-----> Reload server."'
    queue %{
      cd #{deploy_to!}/#{current_path!}
      make reload
    }
  end

end
