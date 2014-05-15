# Class: apache2::ruby
#
# Usage:
# include apache2::ruby

class apache2::mod::ruby {

  apache2::enmod { 'ruby': }
  package { 'libapache2-mod-ruby' :
    ensure => present,
    before => Apache2::Enmod['ruby'],
  }
}
