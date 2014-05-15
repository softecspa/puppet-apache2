# = Define: apache2::directory
#
# This define creates a <Directory></Directory> block under a vhost, with any type of directive.
#
# === Parameters
#
# [*ensure*]
#   present | absent
#
# [*vhost*]
#   Required. Used to refer to a vhost. It must contain apache2::vhost resource name.
#
# [*path*]
#   path searched to apply directive. Required
#
# [*directives*]
#   An array of directives in the form: ['directive1 value','directive2 value']
#
# [*order*]
#   Used to sort the Location block under the same vhost. Default: 0
#
# [*directorymatch*]
#   if true <DirectoryMatch> is used instead of <Directory>. In this case path can be a regex Default: false
#
# === Examples
#
# apache2::vhost {'www.example.com':
#   document_root => '/var/www/www.example.com'
# }
#
# apache2::directory { 'root':
#   vhost      => 'www.example.com',
#   location   => '/var/www/www.example.com/',
#   directives =>  ['AuthType Basic',
#                   'AuthName "Area riservata"',
#                   'AuthBasicProvider file',
#                   'Require valid-user',
#                   'AuthUserFile /var/www/www.example.com/.htusers',
#   ],
# }
define apache2::directory (
  $vhost,
  $path,
  $directives,
  $ensure         = present,
  $order          = '0',
  $directorymatch = false
) {


  if !is_array($directives) {
    $array_directives = [$directives]
  }
  else {
    $array_directives = $directives
  }

  $ensure_fragment = $ensure ? {
    'absent'  => $ensure,
    default   => present
  }

  concat_fragment { "${vhost}+010-directory-${order}.tmp":
    ensure  => $ensure_fragment,
    content => template('apache2/vhost/directory.erb'),
  }

}
