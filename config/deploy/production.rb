# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

role :app, %w{w3dynamica@ono.rrv.ru:2222}
role :web, %w{w3dynamica@ono.rrv.ru:2222}
role :db,  %w{w3dynamica@ono.rrv.ru:2222}

set :application, 'dynamica'
set :deploy_to, '/www/dynamica.cc'
set :branch, :master