#
# Cookbook Name:: prose
# Recipe:: default
#

include_recipe 'apt'
include_recipe 'build-essential'
include_recipe 'nodejs::nodejs_from_binary'
include_recipe 'runit'
include_recipe 'nginx'
include_recipe 'omnibus'

package 'curl'

app_name = 'prose'
node_attrs = node[app_name]
user_name = node_attrs['user']['name']
user_home = node_attrs['user']['home']
group_name = node_attrs['group']
prose_dir = node_attrs['prose_dir']
gatekeeper_dir = node_attrs['gatekeeper_dir']
gatekeeper_url = "http://#{node_attrs['gatekeeper_host']}:#{node_attrs['gatekeeper_port']}"
github_app_creds = encrypted_data_bag_item_for_environment('keys', 'github')['apps'][app_name]

[user_home, "#{user_home}/.npm", '/usr/local/lib/node_modules', prose_dir, gatekeeper_dir].each do |name|
  directory name do
    owner user_name
    group group_name
    recursive true
  end
end

settings = {
  'oauth_client_id' => github_app_creds['client-id'],
  'oauth_client_secret' => github_app_creds['client-secret'],
  'gatekeeper_user' => user_name,
  'gatekeeper_dir' => gatekeeper_dir,
  'gatekeeper_url' => gatekeeper_url,
  'gatekeeper_port' => node_attrs['gatekeeper_port'],
  'prose_port' => node_attrs['prose_port'],
  'prose_dir' => prose_dir
}

git prose_dir do
  repository 'https://github.com/prose/prose.git'
  revision 'master'
  user user_name
  group group_name
  notifies :run, 'execute[prose-install]', :delayed
end

template "#{prose_dir}/oauth.json" do
  source 'oauth.json.erb'
  variables({ 'settings' => settings })
  notifies :run, 'execute[prose-install]', :delayed
end

execute 'prose-install' do
  cwd prose_dir
  command 'npm install -g gulp'
  action :nothing
  notifies :run, 'execute[prose-build]', :immediately
end

execute 'prose-build' do
  cwd prose_dir
  command 'npm install && gulp --prod'
  action :nothing
  notifies :restart, 'service[nginx]', :delayed
end

template '/etc/nginx/sites-available/prose' do
  source 'prose.conf.erb'
  variables({ 'settings' => settings })
  notifies :restart, 'service[nginx]', :delayed
end

nginx_site 'prose'

git gatekeeper_dir do
  repository 'https://github.com/prose/gatekeeper.git'
  revision 'master'
  user user_name
  group group_name
  notifies :run, 'execute[gatekeeper-install]', :immediately
end

template "#{gatekeeper_dir}/config.json" do
  source 'config.json.erb'
  variables({ 'settings' => settings })
  notifies :restart, 'service[gatekeeper]', :delayed
end

execute 'gatekeeper-install' do
  cwd gatekeeper_dir
  command 'npm install'
  action :nothing
  notifies :restart, 'service[gatekeeper]', :delayed
end

runit_service 'gatekeeper' do
  default_logger true
  options(settings)
end
