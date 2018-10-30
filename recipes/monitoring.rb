if node['base']['monitoring']['enabled']

  directory "/etc/zabbix/zabbix_agent.d" do
    recursive true
    action :create
  end

  package "zabbix-agent" do
    action :install
  end

  service "zabbix-agent" do
    action :start
  end

  template "/etc/zabbix/zabbix_agentd.conf" do
    action :create
    notifies :restart, "service[zabbix-agent]"
    variables ({
      :hostname => node['base']['monitoring']['hostname'] || node['hostname'],
      :user_params => node['base']['monitoring']['user_params'],
      :server => node['base']['monitoring']['server']
    })
  end

  cookbook_file "/etc/sudoers.d/zabbix" do
    mode 0440
    owner "root"
    group "root"
    action :create
  end
else
  package "zabbix-agent" do
    action :remove
  end
end
