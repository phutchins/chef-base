include_recipe "apt"
#if platform?("ubuntu")
#  execute "apt_get_update" do
#    command "apt-get update"
#    not_if { ::File.exists?('/usr/bin/screen') }
#  end
#end

#if platform?("fedora")
#  execute "yum_update" do
#    command "yum update"
#    not_if { ::File.exists?('/usr/bin/screen') }
#  end
#end

%w[git vim htop bmon zsh iftop tmux screen iotop nmon vnstat].each do |pkg|
  package pkg do
    action :install
  end
end
