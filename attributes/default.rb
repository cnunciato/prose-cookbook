#
# Cookbook Name:: prose
# Attribute:: default
#

node.default['prose']['user']['home']       = '/home/prose'
node.default['prose']['user']['name']       = 'prose'
node.default['prose']['group']              = 'prose'
node.default['prose']['prose_dir']          = '/srv/prose'
node.default['prose']['prose_port']         = 9998
node.default['prose']['gatekeeper_dir']     = '/srv/gatekeeper'
node.default['prose']['gatekeeper_host']    = '33.33.33.133'
node.default['prose']['gatekeeper_port']    = 9999

node.default['omnibus']['build_user_home']  = '/home/prose'
node.default['omnibus']['build_user']       = 'prose'
node.default['omnibus']['build_user_group'] = 'prose'
node.default['omnibus']['ruby_version']     = '2.1.2'
