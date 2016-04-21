#
# Cookbook Name:: chef-base
# Recipe:: default
#
# Copyright (c) 2014 The Authors, All Rights Reserved.

include_recipe 'chef-client'
include_recipe 'chef-client::config'
include_recipe 'chef-base::app-packages'
include_recipe 'chef-base::monitoring'
include_recipe 'chef-base::users'
include_recipe 'chef-base::vpn'
include_recipe 'chef-base::sshd'
include_recipe 'chef-iptables::iptables'
include_recipe 'chef-base::sar'
