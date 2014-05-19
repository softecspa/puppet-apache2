class apache2::logrotate {

  include apache2::params

  logrotate::file { 'apache2':
    log          => '/var/log/apache2/*.log',
    interval     => 'daily',
    rotation     => '30',
    options      => [ 'missingok', 'compress', 'notifempty', 'delaycompress', 'sharedscripts' ],
    archive      => true,
    olddir       => '/var/log/apache2/archives',
    olddir_owner  => $apache2::logrotate_olddir_owner,
    olddir_group  => $apache2::logrotate_olddir_group,
    olddir_mode   => $apache2::logrotate_olddir_mode,
    create        => "${apache2::logrotate_create_mode} ${apache2::logrotate_create_owner} ${apache2::logrotate_create_group}",
    postrotate   => 'if [ -f "`. /etc/apache2/envvars ; echo ${APACHE_PID_FILE:-/var/run/apache2.pid}`" ]; then
                      /etc/init.d/apache2 reload > /dev/null
                      fi';
  }
}
