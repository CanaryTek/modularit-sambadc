# Author:: Kuko Armas
# Cookbook Name:: modularit-sambadc
# Attribute:: member

## Packages
case node['platform_family']
when 'rhel','fedora'
  default['samba']['member']['packages'] = %w[samba-winbind authconfig pam_krb5 samba-winbind-clients]
else
  default['samba']['member']['packages'] = %w[samba-winbind authconfig pam_krb5 samba-winbind-clients]
end

