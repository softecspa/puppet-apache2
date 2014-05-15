class apache2::params {

  $apache2dir             = '/etc/apache2'
  $reloadfile             = "${apache2dir}/.last-reload"
  $dirconf                = 'dir.conf'
  $apachecusttemplate1    = 'apache2-softec'
  $apache2confd           = "${apache2dir}/conf.d"
  $logrotatedir           = '/etc/logrotate.d'
  $apache2includes        = '/etc/apache2/includes.d'
  $apache2_max_open_files = '8192'
  $error_log_dir          = '/var/log/apache2'
  $access_log_dir         = '/var/log/apache2'
  $sites_available_dir    = "$apache2dir/sites-available"
  $sites_enabled_dir      = "$apache2dir/sites-enabled"
  $docroot                = '/var/www'

  $packages = [ 'apache2',
                'apache2-doc',
                'apache2-mpm-prefork',
                'apache2-utils',
                'libexpat1']

  if defined(Nfs::Mount[$docroot]) {
    $service_require  = Nfs::Mount[$docroot]
  } else {
    $service_require  = undef
  }
}
