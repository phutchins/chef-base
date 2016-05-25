if node['base']['monitoring']['bandwidth']['enabled']
  node.set['base']['monitoring']['user_params'] = {
    'net.bandwidth[*]' => '/usr/local/bin/bandwidth_monitor.sh $1 $2 $3'
  }

  package 'vnstat' do
    action :install
  end

  cookbook_file '/usr/local/bin/bandwidth_monitor.sh' do
    mode '0755'
    action :create
  end
else
  node.rm('base', 'monitoring', 'bandwidth', 'net.bandwidth[*]')

  package 'vnstats' do
    action :remove
  end
end
