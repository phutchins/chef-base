require_relative '../spec_helper'

describe 'chef-base::users' do
  subject { ChefSpec::ServerRunner.new.converge(described_recipe) }

  # Write quick specs using `it` blocks with implied subjects
  #node['base']['users'].each do |username, fullname|
  #  it { should create_user(username).with(username: username) }
  #end

  # Write full examples using the `expect` syntax
  #it 'creates users' do
  #  node['base']['users'].each do |username, fullname|
  #    expect(subject).to create_user(username)
  #  end
  #end

  # Use an explicit subject
  #let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  #it 'does something' do
  #  expect(chef_run).to do_something('...')
  #end
end
