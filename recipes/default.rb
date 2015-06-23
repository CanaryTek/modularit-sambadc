#
# Cookbook Name:: modularit-sambadc
# Recipe:: default
#
# Copyright 2013, CanaryTek
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Add modularit-zimbra role
node.run_list << "role[modularit-sambadc]"

case node['platform']
when "centos","redhat"
  include_recipe 'yum'
  include_recipe "yum::epel"
end

# Install build dependencies
packages = node['samba']['build_deps'].split
packages.each do |pkg|
  package pkg do
    action :install
  end
end

version = node['samba']['server']['version']

remote_file "#{Chef::Config[:file_cache_path]}/#{node['samba']['server']['download_file']}" do
  source "#{node['samba']['server']['download_url']}/#{node['samba']['server']['download_file']}"
  action :create_if_missing
end

bash "Compile and Install Samba" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar zxvf #{node['samba']['server']['download_file']}
    cd samba-*
    ./configure --enable-selftest
    make
    make install
  EOH
  creates "/usr/local/samba/sbin/samba"
end

## NTP
package "ntp"

cookbook_file "/etc/ntp.conf" do
  source 'ntp.conf'
  mode 00644
  notifies :restart, 'service[ntpd]'
end

directory "/usr/local/samba/var/lib/ntp_signd" do
  owner  "root"
  group "ntp"
  mode 00750
end

service "ntpd" do
  action [:start, :enable]
end

# Profile path to include samba un path
cookbook_file "/etc/profile.d/samba.sh" do
  source 'samba_profile.sh'
  mode 00644
end

# Samba service
cookbook_file "/etc/init.d/samba4" do
  source 'samba4.init'
  mode 00755
#  notifies :reload, 'service[samba4]'
end

#service "samba4" do
#  action [:start, :enable]
#end

## Scripts for deploying and testing
directory "/root/bin"

template "/root/bin/deploy_ad.sh" do
  source "deploy_ad.sh.erb"
  mode 00755
end

template "/root/bin/test_samba_basic.sh" do
  source "test_samba_basic.sh.erb"
  mode 00755
end
