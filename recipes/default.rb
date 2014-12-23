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

case node['platform']
when "centos","redhat"
  bash "Workaround for http://tickets.opscode.com/browse/COOK-1210" do 
    code <<-EOH
      echo 0 > /selinux/enforce
    EOH
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
  notifies :reload, 'service[ntpd]'
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

bash "provision-samba" do
  code <<-EOH
    /usr/local/samba/bin/samba-tool domain provision --use-rfc2307 \
        --realm #{node['samba']['server']['realm']} \
        --host-name #{node['samba']['server']['hostname']} \
        --domain #{node['samba']['server']['domain']} \
        --server-role #{node['samba']['server']['role']} \
        --adminpass #{node['samba']['server']['adminpass']}
    cp /usr/local/samba/private/krb5.conf /etc/krb5.conf
    echo "search #{node['samba']['server']['realm']}\nnameserver 127.0.0.1" > /etc/resolv.conf
  EOH
  creates "/usr/local/samba/etc/smb.conf"
end

# Samba service
cookbook_file "/etc/init.d/samba4" do
  source 'samba4.init'
  mode 00755
  notifies :reload, 'service[samba4]'
end

service "samba4" do
  action [:start, :enable]
end

## Scripts for testing
directory "/root/bin"

template "/root/bin/test_samba_basic.sh" do
  source "test_samba_basic.sh.erb"
  mode 00755
end
