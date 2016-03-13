maintainer        "Kuko Armas"
name              "modularit-sambadc"
maintainer_email  "kuko@canarytek.com"
license           "Apache 2.0"
description       "Installs and configure a Samba4 AD DC"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.1.0"
recipe            "modularit-sambadc", "Installs and configures a Samba4 AD DC"

%w{apt yum yum-epel}.each do |pkg|
  depends pkg
end

%w{redhat centos}.each do |os|
  supports os
end
