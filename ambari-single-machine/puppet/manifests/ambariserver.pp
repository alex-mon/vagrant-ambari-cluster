# VM-Configuration of the ambari server. It functions as the name node and resource manager.

# Turn off interfering services
#include interfering_services
class { 'interfering_services': } ->

# Install and enable ntp
class { 'ntp': } ->

package { 'openssh-server': ensure => 'installed' } ->

hosts::populate { 'add ips to hosts file':
  master_name     => $master_hostname,
  node_base_name  => $node_base_name,
  domain_subfix   => $domain_subfix,
  cluster_size    => $cluster_size,
  base_ip         => $base_ip
} ->

# Install and enable ambari server
class { 'ambari_server':
  ownhostname => "${master_hostname}${domain_subfix}"
}

# Install and enable ambari agent
class { 'ambari_agent':
  ownhostname    => "${master_hostname}${domain_subfix}",
  serverhostname => "${master_hostname}${domain_subfix}"
}
