class apache2::logrotate {

  include apache2::params

  logrotate::file { 'apache2':
    log          => '/var/log/apache2/*.log',
    interval     => 'daily',
    rotation     => '30',
    options      => [ 'missingok', 'compress', 'notifempty', 'delaycompress', 'sharedscripts' ],
    archive      => true,
    olddir       => '/var/log/apache2/archives',
    olddir_owner => 'root',
    olddir_group => 'super',
    olddir_mode  => '644',
    create       => '664 root super',
    postrotate   => 'if [ -f "`. /etc/apache2/envvars ; echo ${APACHE_PID_FILE:-/var/run/apache2.pid}`" ]; then
                      /etc/init.d/apache2 reload > /dev/null
                      fi';
  }
}
