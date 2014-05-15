# Class: apache2::mod::status
#
# Usage:
# include apache2::mod::status
#
class apache2::mod::status {

  apache2::enmod { 'status': }
  $subnet_regex = $::apache2_subnet_regex

  file { '/etc/apache2/mods-available/status.conf':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('apache2/status.conf'),
  }

  file { '/etc/apache2/mods-enabled/status.conf':
    ensure  => 'link',
    target  => '../mods-available/status.conf',
    require => File['/etc/apache2/mods-available/status.conf'],
  }

}