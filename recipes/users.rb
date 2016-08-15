my_users = []

# Add all users in the admin group
search(:users, "group:admin").each do |result_user|
  my_users << result_user
end

# For this environment, add ssh account for all users in allowed groups
if !node['users'].nil? && !node['users']['groups'].nil? then
  node['users']['groups'].each do |group|
    search(:users, "group:#{group}").each do |result_user|
      my_users << result_user
    end
    search(:users, "add_groups:#{group}").each do |result_user|
      my_users << result_user
    end
  end
end

if !node['users'].nil? && !node['users']['sudo_groups'].nil? then
  node['users']['sudo_groups'].each do |group|
    search(:users, "group:#{group}").each do |result_user|
      my_users << result_user
    end
    search(:users, "add_groups:#{group}").each do |result_user|
      my_users << result_user
    end
  end
end

if !node['users'].nil? && !node['users']['sudo_users'].nil? then
  node['users']['sudo_users'].each do |username|
    search(:users, "id:#{username}").each do |result_user|
      my_users << result_user
    end
  end
end
my_users.uniq!

group 'staff' do
  action :create
end

# Add all of the users that we found that need ssh accounts
my_users.each do |my_user|
  home_dir = my_user['home_dir'] || File.join('/home', my_user['id'])
  group my_user['unix_group'] do
    action :create
  end unless my_user['unix_group'].nil?

  user my_user['id'] do
    comment my_user['name']
    gid my_user['unix_group'] || 'staff'
    home home_dir
    manage_home true
    shell my_user['unix_shell'] || '/bin/bash'
    if my_user['disabled']
     action :remove
    end
  end

  my_user['add_unix_groups'].each do |unix_group|
    group unix_group do
      append true
      if my_user['disabled']
        excluded_members my_user['id']
        action :modify
      else
        members my_user['id']
        action :create
      end
    end
  end unless my_user['disabled'] || my_user['add_unix_groups'].nil?


  if !my_user['disabled']
    [home_dir, File.join(home_dir, "/.ssh")].each do |dir|
      directory dir do
        mode 0700
        owner my_user['id']
        group my_user['unix_group'] || 'staff'
        action :create
      end
    end unless my_user['disabled']

    template"#{home_dir}/.ssh/authorized_keys" do
      mode 0600
      owner my_user['id']
      group my_user['unix_group'] || 'staff'
      variables ({
        :keys => my_user['ssh_pub_keys']
      })
      action :create
    end unless my_user['ssh_pub_keys'].nil?

    if my_user['custom_bashrc'] then bashrc_source = "#{my_user['id']}.bashrc" else bashrc_source = "default.bashrc" end
    cookbook_file "#{home_dir}/.bashrc" do
      source bashrc_source
      owner my_user['id']
      group my_user['unix_group']
      action :create
      ignore_failure true
    end

    if (my_user['custom_vimrc'] == true && node['chef_environment'] != 'extprod')
      vimrc_source = "#{my_user['id']}.vimrc"
      cookbook_file "#{home_dir}/.vimrc" do
        source vimrc_source
        owner my_user['id']
        group my_user['unix_group']
        action :create
        ignore_failure true
      end
    end
  else
    if home_dir != '/home'
      directory home_dir do
        recursive true
        action :delete
      end
    end
  end
end

cookbook_file "/etc/sudoers.d/sudoers" do
  mode 0440
  owner "root"
  group "root"
  action :create
end

sudoers = []
remove_sudoers = []
remove_admins = []

# Find all users that should be sudoers
if !node['users'].nil? && !node['users']['sudo_groups'].nil? then
  # Add all admins to sudoers
  search(:users, "group:admin").each do |result_user|
    if !result_user['disabled']
      sudoers << result_user['id']
    else
      remove_admins << result_user['id']
      remove_sudoers << result_user['id']
    end
  end

  # Add all users in admin add_groups to sudoers
  search(:users, "add_groups:admin").each do |result_user|
    if !result_user['disabled']
      sudoers << result_user['id']
    else
      remove_admins << result_user['id']
      remove_sudoers << result_user['id']
    end
  end

  # Add all users in this environments sudo_groups group array to sudoers
  node['users']['sudo_groups'].each do |group|
    search(:users, "group:#{group}").each do |result_user|
      if !result_user['disabled']
        sudoers << result_user['id']
      else
        remove_sudoers << result_user['id']
      end
    end

    # Add all users with add_group matching this env's sudo_group list to sudoers
    search(:users, "add_groups:#{group}").each do |result_user|
      if !result_user['disabled']
        sudoers << result_user['id']
      else
        remove_sudoers << result_user['id']
      end
    end
  end
end

# TODO: Remove users from groups that they are no longer in!

group 'admin' do
  excluded_members remove_admins
  append true
end

group 'sudoers' do
  members sudoers
  excluded_members remove_sudoers
  append true
end
