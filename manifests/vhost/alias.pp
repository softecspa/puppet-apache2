# == Define: apache2::vhost::alias
#
# This define creates a alias directive included in vhost definition.
# It creates a fragment that is concatenated to the other vhost fragment created by apache2::vhost directive
#
# === Parameters
#
# [*vhost*]
#   It must be the apache2::vhost define name of the virtualhost wich is related. Mandatory
#
# [*path*]
#   First argument of apache2 Alias directive. Mandatory
#
# [*target*]
#   Second argument of apache2 Alias directive. Mandatory
#
# [*order*]
#   if more apache::vhost::alias is used on the same virtualhost, this parameter can be used to order alias directive in virtualhost definition. Default: 0
#
# === Examples
#
# 1 - create a virtualhost named www.example.com having following Alias directive:
#   "Alias /example1 /var/www/www.example.com/htdocs/examples/1"
#
#   apache2::vhost { 'www.example.com':
#     document_root => '/var/www/www.example.com',
#   }
#
#   apache2::vhost::alias {'example1':
#     vhost   => 'www.example.com',
#     path    => '/example1',
#     target  => '/var/www/www.example.com/htdocs/examples/1',
#   }
#
# 2 - create a virtualhost named www.example.com having following Alias directives in the order they are written:
#   "Alias /example1 /var/www/www.example.com/htdocs/examples/1"
#   "Alias /example2 /var/www/www.example.com/htdocs/examples/2"
#
#   apache2::vhost { 'www.example.com':
#     document_root => '/var/www/www.example.com',
#   }
#
#   apache2::vhost::alias {'example1':
#     vhost   => 'www.example.com',
#     path    => '/example1',
#     target  => '/var/www/www.example.com/htdocs/examples/1',
#     order   => "1"
#   }
#
#   apache2::vhost::alias {'example2':
#     vhost   => 'www.example.com',
#     path    => '/example2',
#     target  => '/var/www/www.example.com/htdocs/examples/2',
#     order   => "2"
#   }
#
define apache2::vhost::alias (
  $vhost,
  $path,
  $target,
  $order = '0'
) {

  concat_fragment { "${vhost}+030-alias-${order}-${name}.tmp":
    content => "    Alias $path \"$target\"",
  }

}
