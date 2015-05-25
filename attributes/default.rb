# Author:: Kuko Armas
# Cookbook Name:: modularit-sambadc
# Attribute:: default

##  Default Samba attributes
default['samba']['server']['hostname'] = "samba1"
default['samba']['server']['realm'] = "domain.local"
default['samba']['server']['domain'] = "DOMAIN"
default['samba']['server']['role'] = "dc"
default['samba']['server']['adminpass'] = "P@ssW0rd01"

## Build time attributes. You should not need to change them
default['samba']['server']['version'] = "4.2.1"
default['samba']['server']['download_url'] = "http://ftp.samba.org/pub/samba"
default['samba']['server']['download_file'] = "samba-#{node['samba']['server']['version']}.tar.gz"

case node['platform_family']
when 'rhel','fedora'
  default['samba']['build_deps'] = 'gcc make wget python-devel gnutls-devel openssl-devel libacl-devel krb5-server krb5-libs krb5-workstation bind bind-libs bind-utils openldap-devel ncurses-devel'
else
  default['samba']['build_deps'] = 'gcc make wget python-devel gnutls-devel openssl-devel libacl-devel krb5-server krb5-libs krb5-workstation bind bind-libs bind-utils openldap-devel ncurses-devel'
end

