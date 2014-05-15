# == Define: apache2::vhost
#
# This define creates a virtual host under sites-available
#
# === Parameters
#
# [*ensure*]
# It can be:
#   - present: conf file is linked under sites-enabled
#   - disabled: conf file is not deleted but is not linked under sites-enabled
#   - absent: conf file and link under sites-enabled are deleted
#
# [*create_docroot*]
#   If set to true document root will be created if it don't exists. Default: false
#
# [*server_name*]
#   ServerName apache directive. If it's blank, $name is used
#
# [*server_aliases*]
#   ServerAlias apache directive. It can be a string with single alias or an array of aliases
#
# [*server_admin*]
#   ServerAdmin apache2 directive
#
# [*listen_ip*]
#   IP address associated with VH. * is default
#
# [*listen_port*]
#   Port on which VH will listen. $www_port variable is the default
#
# [*document_root*]
#   DocumentRoot apache2 directive. Required
#
# [*error_log*]
#   ErrorLog apache2 directive. Default ${apache2::params::error_log_dir}/${server_name}_error.log
#
# [*access_log*]
#   AccessLog apache2 directive. Default ${apache2::params::access_log_dir}/${server_name}_access.log
#
# [*template*]
#   Option template to use instead of default template. This template is used as header fragment in vhost configuration file generation.
#   It must NOT contain </Virtualhost> directive because it's present in footer fragment.
#
# === Examples
#
# 1 - Using default parameter
#
#   apache2::vhost { 'www.example.com':
#     document_root => '/var/www/www.example.com',
#   }
#
# 2 - Complete example
#
#   apache2::vhost { 'www.example.com':
#     server_aliases  => ['example.com','ww2.example.com'],
#     listen_ip       => '192.168.1.1'.
#     listen_port     => '8080',
#     document_root   => '/var/www/www.example.com',
#     error_log       => '/var/log/apache2/example_error.log',
#     access_log      => '/var/log/apache2/example_access.log',
#     template        => 'apache2/vhost/custom_template.erb',
#   }
#
define apache2::vhost (
  $document_root,
  $create_docroot = false,
  $ensure         = 'present',
  $server_name    = '',
  $server_aliases = '',
  $server_admin   = '',
  $listen_ip      = '*',
  $listen_port    = $www_port,
  $error_log      = '',
  $access_log     = '',
  $template       = 'apache2/vhost/vhost_header.erb',
) {

  include apache2

  $servername = $server_name ? {
    ''      => $name,
    default => $server_name,
  }

  $errorlog = $error_log ? {
    ''      => "${apache2::params::error_log_dir}/${servername}_error.log",
    default => $errorlog
  }

  $accesslog = $access_log ? {
    ''      => "${apache2::params::access_log_dir}/${servername}_access.log",
    default => $accesslog
  }

  if $server_aliases != '' {
    if !is_array($server_aliases) {
      $array_aliases = [$server_aliases]
    }
    else {
      $array_aliases = $server_aliases
    }
  }

  $aliases = $server_aliases ? {
    ''      => $server_aliases,
    default => $array_aliases
  }

  if (! defined(File[$document_root])) and ($create_docroot) {
    file { $document_root:
      ensure  => directory,
      mode    => '2775',
    }
  }

  $ensure_site_available = $ensure ? {
    'disabled'  => 'present',
    default     => $ensure
  }

  # FIXME: selector inside resource: validate ensure outside resource block
  file { "${apache2::params::sites_available_dir}/$servername":
    ensure  => $ensure_site_available,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Concat_build[$servername],
  }

  $ensure_site_enabled = $ensure ? {
    'present' => link,
    default => 'absent'
  }

  file { "${apache2::params::sites_enabled_dir}/$servername":
    ensure  => $ensure_site_enabled,
    target  => "${apache2::params::sites_available_dir}/$servername",
    require => File["${apache2::params::sites_available_dir}/$servername"]
  }

  concat_build { $servername:
    order         => ['*.tmp'],
    target        => "${apache2::params::sites_available_dir}/$servername",
    notify        => Service['apache2'],
  }

  concat_fragment { "${servername}+001.tmp":
    content => template($template),
  }

  concat_fragment { "${servername}+999.tmp":
    content => '</VirtualHost>',
  }

}
