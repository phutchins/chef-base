service 'sshd' do
  if platform?("ubuntu")
    provider Chef::Provider::Service::Upstart
  end

  case node['platform']
  when 'debian'
    service_name 'ssh'
  when 'ubuntu'
    service_name 'ssh'
  else
    service_name 'sshd'
  end
  supports :status => true, :restart => true
end

template "/etc/ssh/sshd_config" do
  action :create
  mode 0644
  owner 'root'
  group 'root'
  variables ({
    :listen_port => node['base']['sshd']['listen_port'],
    :password_login => node['base']['sshd']['password_login']
  })
  notifies :restart, "service[sshd]", :immediately
end

#ruby_block "change sshd port" do
#  changed = false
#  block do
#    fe = Chef::Util::FileEdit.new("/etc/ssh/sshd_config")
#    fe.search_file_replace(/Port 22/, "Port #{node['base']['sshd']['listen_port']}")
#    fe.write_file
#    changed = fe.file_edited?
#    Chef::Log.info("SSHD Config File Edit Status: #{changed}")
#  end
#  if changed
#    notifies :restart, "service[ssh]", :immediately
#  end
#  #only_if { ::File.readlines("/etc/ssh/sshd_config").grep("Port 22").any? }
#end
