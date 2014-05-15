# Class: apache2::jk
#
# Usage:
# include apache2::jk

class apache2::mod::jk {

  apache2::enmod { 'jk': }
  package { 'libapache2-mod-jk':
    ensure => present,
    before => Apache2::Enmod['jk'],
  }

}
