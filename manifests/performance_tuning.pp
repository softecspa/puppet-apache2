# == Define apache2::performance_tuning
#
# This define manage tuning of apache2. It push files in /etc/apache2/conf.d
# This define is a wrapper of apache2::paramfile. See apache2::paramfile doc for more specific tuning
#
# === Parameters
#
# [*filename*]
#   filename where directive are written, under /etc/apache2/conf.d directory. If isn't set, <name> will ben used
# [*max_clients*]
#   apache2 tuning parameter. Default: 100
# [*max_requests_per_child*]
#   apache2 tuning parameter. Default: 10000
# [*max_spare_servers*]
#   apache2 tuning parameter. Default: 60
# [*min_spare_servers*]
#   apache2 tuning parameter. Default: 40
# [*start_servers*]
#   apache2 tuning parameter. Default: 35
# [*enable_MMAP*]
#   apache2 tuning parameter. Default: Off
# [*enable_sendfile*]
#   apache2 tuning parameter. Default: Off
# [*keepalive*]
#   apache2 tuning parameter. Default: On
# [*keepalive_timeout*]
#   apache2 tuning parameter. Default: 5
# [*max_keepalive_requests*]
#   apache2 tuning parameter. Default: 100
# [*timeout*]
#   apache2 tuning parameter. Default: 60
# [*graceful_shutdown_timeout*]
#   apache2 tuning parameter. Default: 60
#

define apache2::performance_tuning (
  $filename                   = '',
  $max_clients                = '100',
  $max_requests_per_child     = '10000',
  $max_spare_servers          = '60',
  $min_spare_servers          = '40',
  $start_servers              = '35',
  $enable_MMAP                = 'Off',
  $enable_sendfile            = 'Off',
  $keepalive                  = 'On',
  $keepalive_timeout          = '5',
  $max_keepalive_requests     = '100',
  $timeout                    = '60',
  $graceful_shutdown_timeout  = '60',
) {

  if !is_integer($max_clients) {
    fail ('parameter max_clients must be an integer value')
  }

  if !is_integer($max_requests_per_child) {
    fail ('parameter max_requests_per_child must be an integer value')
  }

  if !is_integer($max_spare_servers) {
    fail ('parameter max_spare_servers must be an integer value')
  }

  if !is_integer($min_spare_servers) {
    fail ('parameter min_spare_servers must be an integer value')
  }

  if !is_integer($start_servers) {
    fail ('parameter start_servers must be an integer value')
  }

  if !is_integer($keepalive_timeout) {
    fail ('parameter keepalive_timeout must be an integer value')
  }

  if !is_integer($max_keepalive_requests) {
    fail ('parameter max_keepalive_requests must be an integer value')
  }

  if !is_integer($timeout) {
    fail ('parameter timeout must be an integer value')
  }

  if !is_integer($graceful_shutdown_timeout) {
    fail ('parameter timeout must be an integer value')
  }

  if $min_spare_servers > $max_spare_servers {
    fail('min_spare_servers must be equal or less than max_spare_servers')
  }

  if ($min_spare_servers > $max_clients) or ($max_spare_servers > $max_clients) or ($start_servers > $max_clients) {
    fail('min_spare_server and max_spare_servers must be less than max_clients')
  }

  $file = $filename? {
    ''      => $name,
    default => $filename,
  }

  apache2::paramfile { $file :
    params    => {
      'StartServers'          => $start_servers,
      'MaxClients'            => $max_clients,
      'MinSpareServers'       => $min_spare_servers,
      'MaxSpareServers'       => $max_spare_servers,
      'MaxRequestsPerChild'   => $max_requests_per_child
    },
    ifmodule  => 'mpm_prefork_module',
  }

  apache2::paramfile { "${file}-2":
    params    => {
      'EnableSendfile'          => $enable_sendfile,
      'EnableMMAP'              => $enable_MMAP,
      'Timeout'                 => $timeout,
      'KeepAlive'               => $keepalive,
      'MaxKeepAliveRequests'    => $max_keepalive_requests,
      'KeepAliveTimeout'        => $keepalive_timeout,
      'GracefulShutDownTimeout' => $graceful_shutdown_timeout,
    },
    order     => 2,
    filename  => $file
  }
}
