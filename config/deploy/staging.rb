# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

role :app, %w{w3dev-dynamica@ono.rrv.ru:2223}
role :web, %w{w3dev-dynamica@ono.rrv.ru:2223}
role :db,  %w{w3dev-dynamica@ono.rrv.ru:2223}

set :application, 'dev-dynamica'
set :deploy_to, '/www/dev-dynamica.onomnenado.ru'
set :branch, :master