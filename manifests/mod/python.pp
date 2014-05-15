# Class: apache2::python
#
# Usage:
# include apache2::python

class apache2::mod::python inherits apache2 {

  apache2::enmod { 'python': }
  package { 'libapache2-mod-python':
    ensure => present,
    before => Apache2::Enmod['python'];
  }
}

