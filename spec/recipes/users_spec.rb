require_relative '../spec_helper'

describe 'chef-base::users' do
  let(:chef_run) do
    ChefSpec::ServerRunner.new do |node, server|
      node.set['users']['groups'] = ['dev']
      server.create_data_bag('users', {
        'philip' => {
          'id' => 'philip',
          'name' => 'Philip Hutchins',
          'group' => 'admin',
          'add_groups' => ['dev'],
          'unix_group' => 'staff',
          'sudo_nopasswd' => true,
          'add_unix_groups' => ['admin'],
          'unix_shell' => '/bin/bash',
          'ssh_pub_keys' => ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3Ydkr5Is1MidUr1loNsfvoMLkijY4d+Vvc4MNfxLBBqFpN7IQYP/tO9H3WFK+j59mU6zavVjbntKJWNWUQJNUH1P5QKsq2G4ejCoP0ebxVHDj9YJNAOOGy+smNAxc9hp/l6m3HHOdN99bWq+9gUgzwU3Lh3lnr/dv6EsrCxLGr4183uNpqKO0gzxOqaDrhh3DC801E09JyDH1j3PgJ46gysSsK2oCBTgL4BFeM5k/jMIkutzFlbynB1TXINYgPxSpGCBJS2kAf23tlYzQyY3c0J/qScllaX2ZbF0ad9Fe93QnlzByA6oqymyC4ddLtrBlOtptH5RVDWAxk23oasxj'],
          'cusotm_vimrc' => true,
          'custom_bashrc' => true
        },
        'bob' => {
          'id' => 'bob',
          'name' => 'Bob Builder',
          'group' => 'dev'
        }
      })
    end.converge(described_recipe)
  end

  it 'creates user' do
    expect(chef_run).to create_user("bob")
  end

  it 'creates users .ssh directory and authorized_keys file' do
    expect(chef_run).to create_directory('/home/philip/.ssh').with(
      user: 'philip',
      group: 'staff',
      mode: 0700
    )

    expect(chef_run).to create_template('/home/philip/.ssh/authorized_keys').with(
      user: 'philip',
      group: 'staff',
      mode: 0600
    )

    expect(chef_run).to render_file('/home/philip/.ssh/authorized_keys').with_content('ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3Ydkr5Is1MidUr1loNsfvoMLkijY4d+Vvc4MNfxLBBqFpN7IQYP/tO9H3WFK+j59mU6zavVjbntKJWNWUQJNUH1P5QKsq2G4ejCoP0ebxVHDj9YJNAOOGy+smNAxc9hp/l6m3HHOdN99bWq+9gUgzwU3Lh3lnr/dv6EsrCxLGr4183uNpqKO0gzxOqaDrhh3DC801E09JyDH1j3PgJ46gysSsK2oCBTgL4BFeM5k/jMIkutzFlbynB1TXINYgPxSpGCBJS2kAf23tlYzQyY3c0J/qScllaX2ZbF0ad9Fe93QnlzByA6oqymyC4ddLtrBlOtptH5RVDWAxk23oasxj')
  end

  it 'does not creates users authorized_keys file when no key is provided' do
    expect(chef_run).to_not create_cookbook_file('/home/bob/.ssh/authorized_keys')
  end

  it 'creates bashrc file when included' do
    expect(chef_run).to create_cookbook_file('/home/bob/.bashrc')
  end

  it 'creates sudoers file adding sudo for users in the sudoers group' do
    expect(chef_run).to create_cookbook_file('/etc/sudoers.d/sudoers').with(
      user: 'root',
      group: 'root',
      mode: 0440
    )
  end

  it 'adds user that belongs to sudo_groups to the sudoers unix group' do
    expect(chef_run).to create_group('sudoers')
    # Need to confirm that the user was added to the sudoers group if they should have been and not if they should not
  end
end
