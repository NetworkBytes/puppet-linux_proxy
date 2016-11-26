class linux_proxy {
  include 'linux_proxy::profiles'
  include 'linux_proxy::yum'
  if hiera('linux_proxy::rhsm::enabled', false) {
    include 'linux_proxy::rhsm'
  }
}


# BASH PROFILES
class linux_proxy::profiles (
  Boolean $enabled,
  $no_proxy = [],
  $proxy_address  = '', 
) {

  if $enabled {
    file { '/etc/profile.d/proxy.sh':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("$module_name/proxy.sh.erb"),
    }
  } else {
    file { '/etc/profile.d/proxy.sh': ensure => absent }
  }
}


# YUM
class linux_proxy::yum (
  Boolean $enabled,
  $proxy_address  = "", 
) {

  if $enabled {
    file_line { "yum.conf_Proxy":
      path => '/etc/yum.conf',
      match => "^proxy=.*$",
      line => "proxy=http://$proxy_address"
    }
  } else {
    file_line { "yum.conf_Proxy_remove":
      ensure => absent,
      path => '/etc/yum.conf',
      match => "^proxy=.*$",
      line => "proxy=http://$proxy_address"
    }
  } 
}

# REDHAT SUBSCRIPTION MANAGER
class linux_proxy::rhsm (
  Boolean $enabled,
  $proxy_hostname, 
  $proxy_port
) {

  if $enabled {
    exec { "/usr/sbin/subscription-manager config --server.proxy_host='$proxy_hostname'":}
    exec { "/usr/sbin/subscription-manager config --server.proxy_port='$proxy_port'":}
  } 

}
