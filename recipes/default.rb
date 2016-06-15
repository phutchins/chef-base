#
# Cookbook Name:: chef-base
# Recipe:: default
#
# Copyright (c) 2014 The Authors, All Rights Reserved.
#

case node['platform']
when 'debian'
  # node.set['chef_client']['init_style'] = 'systemd'
  node.set['chef_client']['init_style'] = 'init'
end

include_recipe 'chef-client'
include_recipe 'chef-client::config'
include_recipe 'chef-base::app-packages'
include_recipe 'chef-base::bandwidth-monitoring'
include_recipe 'chef-base::monitoring'
include_recipe 'chef-base::users'
include_recipe 'chef-base::vpn'
include_recipe 'chef-base::sshd'

if node['base']['iptables']['enabled']
  include_recipe 'chef-iptables::iptables'
end

if node['base']['iptables']['remove']
  include_recipe 'chef-iptables::iptables-remove'
end

include_recipe 'chef-base::sar'
