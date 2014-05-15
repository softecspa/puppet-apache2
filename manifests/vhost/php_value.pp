# == Define: apache2::vhost::php_value
#
# This define creates a php_value or php_admin_value directive included in virtualhost definition
# It creates a fragment that is concatenated to the other vhost fragment created by apache2::vhost directive
#
# === Parameters
#
# [*vhost*]
#   It must be the apache2::vhost define name of the virtualhost wich is related. Mandatory
#
# [*admin*]
#   if true php_admin_value will be used, php_value if false. Default: false
#
# [*key*]
#   name of php parameter managed by php_(admin_)value directive. If empty define's name will be used
#
# [*value*]
#   value of php parameter managed by php_(admin_)value directive.
#
# === Examples
#
# 1 - create a virtualhost named www.example.com and set error_reporting to Off with php_admin_value
#
#   apache2::vhost { 'www.example.com':
#     document_root => '/var/www/www.example.com',
#   }
#
#   apache2::vhost::php_value {'error_reporting':
#     vhost   => 'www.example.com',
#     admin   => true,
#     value   => 'Off'
#   }
#
# 2 - create a virtualhost named www.example.com and set open_basedir to /var/www/example.com/htdocs with php_value
#
#   apache2::vhost { 'www.example.com':
#     document_root => '/var/www/www.example.com',
#   }
#
#   apache2::vhost::php_value {'open_basedir':
#     vhost   => 'www.example.com',
#     value   => '"/var/www/example.com/htdocs"'
#   }
#
#
define apache2::vhost::php_value (
  $vhost,
  $admin  = false,
  $key    = '',
  $value  = '',
  $order  = '0',
) {

  validate_bool($admin)

  $directive = $admin? {
    true  => 'php_admin_value',
    false => 'php_value',
  }

  $real_key = $key? {
    ''      => $name,
    default => $key
  }

  concat_fragment { "${vhost}+030-phpvalue-${real_key}-${order}.tmp":
    content => "    ${directive} ${real_key} ${value}",
  }

}
