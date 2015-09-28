#
# Cookbook Name:: modularit-sambadc
# Recipe:: member
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

## Installs a ModularIT Samba4 member server

case node['platform']
when "centos","redhat"
  include_recipe 'yum'
  include_recipe "yum::epel"
end

# Install build dependencies
node['samba']['member']['packages'].each do |pkg|
  package pkg do
    action :install
  end
end

# smb.conf
template "/etc/samba/smb.conf" do
  source "member_smb.conf.erb"
  mode 00755
end

# local.conf
template "/etc/samba/local.conf" do
  source "member_smb_local.conf.erb"
  mode 00755
  action :create_if_missing
end

# Scripts for deploying and testing
directory "/root/bin"

template "/root/bin/deploy_member.sh" do
  source "deploy_member.sh.erb"
  mode 00755
end

## NTP
#package "ntp"

#cookbook_file "/etc/ntp.conf" do
#  source 'ntp.conf'
#  mode 00644
#  notifies :restart, 'service[ntpd]'
#end

#directory "/usr/local/samba/var/lib/ntp_signd" do
#  owner  "root"
#  group "ntp"
#  mode 00750
#end

#service "ntpd" do
#  action [:start, :enable]
#end

