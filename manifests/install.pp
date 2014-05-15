class apache2::install {

  include apache2::params

  package { $apache2::params::packages:
    ensure  => present;
  }

}
