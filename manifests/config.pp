class apache2::config {

  include apache2::params
  include apache2::logrotate

  File {
    owner   => root,
    group   => admin,
    mode    => '0664',
    notify  => Exec['apache2-reload']
  }

  # abilitazione moduli
  apache2::enmod { 'rewrite':}
  apache2::enmod { 'mod-ssl': modulename => 'ssl'}
  apache2::enmod { 'mod-suexec': modulename => 'suexec' }
  apache2::enmod { 'mod-include': modulename => 'include' }
  apache2::enmod { 'mod-expires': modulename => 'expires' }
  apache2::enmod { 'mod-headers': modulename => 'headers' }

  # /etc/apache2/includes.d
  file { $apache2::params::apache2includes:
    ensure  => directory,
  }

  # mods-available
  file { "${apache2::params::apache2dir}/mods-available/${apache2::params::dirconf}":
    ensure  => present,
    source  => "puppet:///modules/apache2/${apache2::params::dirconf}",
    require => Package['apache2'],
    before  => Exec['apache2-reload'],
  }

  file { "${apache2::params::apache2dir}/conf.d/wars":
    ensure  => present,
    source  => 'puppet:///modules/apache2/wars',
  }

  file { "${apache2::params::apache2dir}/conf.d/apache2-doc":
    ensure  => present,
    source  => 'puppet:///modules/apache2/apache2-doc',
    notify  => Exec['apache2-graceful']
  }

  # conf.d/servername
  file { "${apache2::params::apache2confd}/servername":
    ensure  => present,
    content => template('apache2/servername'),
  }

  file { $apache2::params::error_log_dir:
    ensure  => directory,
    mode    => '0755'
  }

  # link simbolico /usr/sbin/apache2 --> /usr/sbin/httpd
  file { '/usr/sbin/httpd':
    ensure  => link,
    target  => '/usr/sbin/apache2',
  }

  #209: num. file aperti
  softec::lib::line { 'apache2-max-open-files':
    ensure  => present,
    file    => '/etc/security/limits.conf',
    line    => "www-data       soft    nofile      ${apache2::params::apache2_max_open_files}",
  }

  # utility per calcolo memoria utilizzata dai fork
  file { '/usr/local/bin/analyzing-apache-memory':
    ensure  => present,
    source  => 'puppet:///modules/apache2/analyzing-apache-memory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { "${apache2::params::apache2dir}/ports.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  $listen_port = $www_port

  augeas { 'apache2_ports':
    context => "/files/${apache2::params::apache2dir}/ports.conf",
    changes => [
      'set directive[1] NameVirtualHost',
      "set directive[1]/arg *:${listen_port}",
      'set directive[2] Listen',
      "set directive[2]/arg ${listen_port}",
      'set IfModule[1]/arg mod_ssl.c',
      'set IfModule[2]/arg mod_gnutls.c',
      'set IfModule[1]/directive Listen',
      'set IfModule[1]/directive/arg 443',
      'set IfModule[2]/directive Listen',
      'set IfModule[2]/directive/arg 443',
    ],
    require => Class['puppet'],
    notify  => Service['apache2'],
  }

  file { "${apache2::params::apache2confd}/security":
    ensure  => present,
    mode    => '0644',
    owner   => root,
    group   => root,
  }

  augeas { 'apache2_security':
    context => "/files/${apache2::params::apache2confd}/security",
    changes => [
      'set directive[1] ServerTokens',
      'set directive[1]/arg Prod',
      'set directive[2] ServerSignature',
      'set directive[2]/arg Off',
      'set directive[3] TraceEnable',
      'set directive[3]/arg Off',
      'set directive[4] FileETag',
      'set directive[4]/arg None',

      'set IfModule/arg mod_ssl.c',
      'set IfModule/#comment \'Paolo Larcheri - 20/11/2009 - prevenire vulnerabilita rilevata da PayPal\'',
      'set IfModule/directive[1] SSLProtocol',
      'set IfModule/directive[1]/arg[1] -ALL',
      'set IfModule/directive[1]/arg[2] +SSLv3',
      'set IfModule/directive[1]/arg[3] +TLSv1',
      'set IfModule/directive[2] SSLCipherSuite',
      'set IfModule/directive[2]/arg ALL:!aNULL:!ADH:!eNULL:!LOW:!EXP:RC4+RSA:+HIGH:+MEDIUM',
    ],
    require => Class['puppet'],
    notify  => Service['apache2'],
  }

  exec { 'email-restart-apache':
    command     => "/bin/echo \"Attenzione, l'esecuzione di puppet su ${::hostname} ha apportato delle modifiche che richiedono un restart di apache \" | mail -s\"${::hostname} apache2 restart needed\" ${apache2::notification_mail}",
    refreshonly => true,
  }
}
