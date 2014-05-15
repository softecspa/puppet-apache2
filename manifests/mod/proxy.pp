# Class: apache2::mod::proxy
#
# Usage:
# include apache2::mod::proxy
#
class apache2::mod::proxy {

  apache2::enmod { 'proxy': }
  apache2::enmod { 'proxy_http': }

  file { '/etc/apache2/mods-available/proxy.conf':
    ensure => present,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/apache2/proxy.conf',
  }

  file { '/etc/apache2/mods-enabled/proxy.conf':
    ensure  => 'link',
    target  => '../mods-available/proxy.conf',
    require => File['/etc/apache2/mods-available/proxy.conf'],
  }

}
