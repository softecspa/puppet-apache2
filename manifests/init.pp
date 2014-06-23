# = Class: apache2
#
# This class install and configure apache2 wbserver.
#
# == Actions:
#   This class makes following actions:
#
#   - install apache2 webserver
#   - enable modules rewrite, ssl, suexec and include
#   - configure dir module
#   - push the following files under conf.d directory
#     - wars:       get .war files unaccessible from the internet
#     - servername: set ServerName directive with fqdn
#     - security:   security fixes
#   - modify through augeas the ports.conf file setting listen directive
#   - push the analyzing-apache-memory utility
#   - configure logrotate
#
# == Requires:
#   - $www_port: [default 80]
#
# == Sample Usage:
#
#   $www_port = "8080"
#   include apache2
#
class apache2 (
  $notification_mail      = $::notifyemail,
  $logrotate_olddir_owner = 'root',
  $logrotate_olddir_group = 'adm',
  $logrotate_olddir_mode  = '0750',
  $logrotate_create_owner = 'root',
  $logrotate_create_group = 'adm',
  $logrotate_create_mode  = '0640',
) inherits apache2::params {

  if $notification_mail == '' {
    fail ('you must define $notification_mail parameter or $::notifyemail global variable')
  }

  if ! is_integer($www_port) {
    fail('variable www_port must be defined and have an integer value')
  }

  include apache2::install
  include apache2::config
  include apache2::service
  #include apache2::tuning

  Class['apache2::install'] ->
  Class['apache2::config'] ->
  #Class['apache2::tuning'] ->
  Class['apache2::service']


}
