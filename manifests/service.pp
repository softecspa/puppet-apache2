# == class apache2::service
#
# Manage apache2 service
#
class apache2::service {

  include apache2::params

  # ricarica la conf
  exec { 'apache2-reload':
    command => "/etc/init.d/apache2 force-reload && touch ${apache2::params::reloadfile}",
    onlyif  => ["/usr/bin/test -n \"`find ${apache2::params::apache2dir} -newer ${apache2::params::reloadfile} 2>&1`\""],
  }

  service { 'apache2':
    ensure      => running,
    hasstatus   => false,
    status      => 'pidof apache2',
    hasrestart  => true,
    enable      => true,
    require     => $apache2::params::service_require
  }

  exec {'apache2-graceful':
    command     => '/usr/sbin/apache2ctl graceful',
    refreshonly => true
  }

}
