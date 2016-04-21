if node['base']['vpn_enabled']
  if platform?("ubuntu")
    execute "apt_get_update" do
      command "apt-get update"
      not_if { ::File.exists?("/etc/openvpn/ca.crt")}
    end
  end

  package "unzip" do
    action :install
  end

  package "openvpn" do
    action :install
  end

  openvpn_service_name = "openvpn"
  if platform?("fedora")
    openvpn_service_name = "openvpn@myco"
  end

  node.set['base']['iptables']['network']['vpn']['iface'] = 'tun0'

  cookbook_file "/etc/openvpn/#{node['hostname']}.zip" do
    action :create
    mode 0600
    notifies :run, "execute[clean_vpn_for_update]", :immediately
    notifies :run, "execute[extract_vpn_files]", :immediately
  end

  execute "clean_vpn_for_update" do
    command "rm /etc/openvpn/ca.crt"
    action :nothing
    ignore_failure true
  end

  execute "extract_vpn_files" do
    command "unzip -o /etc/openvpn/#{node['hostname']}.zip -d /etc/openvpn/"
    not_if do File.exists?("/etc/openvpn/ca.crt") end
  end

  execute "move_vpn_files" do
    command "mv /etc/openvpn/myco.tblk/* /etc/openvpn/"
    only_if do File.exists?("/etc/openvpn/myco.tblk/myco.ovpn") end
  end

  execute "rename_config_file" do
    command "mv /etc/openvpn/myco.ovpn /etc/openvpn/myco.conf"
    only_if do File.exists?("/etc/openvpn/myco.ovpn") end
    if platform?("fedora")
      notifies :restart, "service[openvpn@myco]", :immediately
    else
      notifies :restart, "service[openvpn]", :immediately
    end
  end

  service openvpn_service_name do
    supports :enable => true, :restart => true
    action [ :enable, :start ]
  end

  #execute "cleanup_vpn_zip" do
  #  command "rm /etc/openvpn/#{node['hostname']}.zip"
  #  only_if do File.exists?("/etc/openvpn/#{node['hostname']}.zip") end
  #end

  execute "cleanup_vpn_zip_dir" do
    command "rmdir /etc/openvpn/myco.tblk"
    only_if do File.exists?("/etc/openvpn/myco.tblk") end
  end
else
  package 'openvpn' do
    action :purge
  end

  directory '/etc/openvpn' do
    action :delete
    recursive true
    only_if do File.exists?('/etc/openvpn') end
  end
end
