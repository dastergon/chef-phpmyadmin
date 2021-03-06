#
# Cookbook Name:: phpmyadmin
# Recipe:: default
#
# Copyright 2012, Panagiotis Papadomitsos
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'etc'
require 'digest/sha1'

# PHP Recipe includes we already know PHPMyAdmin needs
if node['phpmyadmin']['stand_alone']
	include_recipe 'php'

	%w{php5-gd php5-mcrypt php5-mysql}.each do |pkg|
		package pkg
	end

	directory node['phpmyadmin']['upload_dir'] do
		owner 'root'
		group 'root'
		mode 01777
		recursive true
		action :create
	end

	directory node['phpmyadmin']['save_dir'] do
		owner 'root'
		group 'root'
		mode 01777
		recursive true
		action :create
	end
end

home = node['phpmyadmin']['home']
user = node['phpmyadmin']['user']
group = node['phpmyadmin']['group']
conf = "#{home}/config.inc.php"

group group do
	action [ :create, :manage ]
end

user user do
	action [ :create, :manage ]
	comment 'PHPMyAdmin User'
	gid group
	home home
	shell '/usr/sbin/nologin'
	supports :manage_home => true
	not_if { (! Etc.getpwnam(user).gecos.eql?('PHPMyAdmin User')) rescue false }
end

directory home do
	owner user
	group group
	mode 00755
	recursive true
	action :create
end

# Download the selected PHPMyAdmin archive
remote_file "#{Chef::Config['file_cache_path']}/phpMyAdmin-#{node['phpmyadmin']['version']}-all-languages.tar.gz" do
  owner user
  group group
  mode 00644
	retries 5
	retry_delay 2
  action :create
  source "#{node['phpmyadmin']['mirror']}/#{node['phpmyadmin']['version']}/phpMyAdmin-#{node['phpmyadmin']['version']}-all-languages.tar.gz"
  checksum node['phpmyadmin']['checksum']
end

bash 'extract-php-myadmin' do
	user user
	group group
	cwd home
	code <<-EOH
		rm -fr *
		tar xzf #{Chef::Config['file_cache_path']}/phpMyAdmin-#{node['phpmyadmin']['version']}-all-languages.tar.gz
		mv phpMyAdmin-#{node['phpmyadmin']['version']}-all-languages/* #{home}/
		rm -fr phpMyAdmin-#{node['phpmyadmin']['version']}-all-languages
	EOH
	not_if { ::File.exists?("#{home}/RELEASE-DATE-#{node['phpmyadmin']['version']}")}
end

directory "#{home}/conf.d" do
	owner user
	group group
	mode 00755
	recursive true
	action :create
end

# Blowfish Secret - set it statically when running on Chef Solo via attribute
unless Chef::Config[:solo] || node['phpmyadmin']['blowfish_secret']
  node.set['phpmyadmin']['blowfish_secret'] = Digest::SHA1.hexdigest(IO.read('/dev/urandom', 2048))
  node.save
end

template "#{home}/config.inc.php" do
	source node['phpmyadmin']['config_template']
	owner user
	group group
	cookbook node['phpmyadmin']['config_template_cookbook']
	mode 00644
end

php_fpm_pool 'phpmyadmin' do
  action :install
  user user
  group group
  listen node['phpmyadmin']['socket']
  start_servers 2
  min_spare_servers 2
  max_spare_servers 8
  max_children 8
  only_if { node['phpmyadmin'].attribute?('fpm') && node['phpmyadmin']['fpm'] }
end
