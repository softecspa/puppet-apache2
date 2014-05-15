# = Define: apache2::location
#
# This define creates a <Location></Location> block under a vhost, with any type of directive.
#
# === Parameters
#
# [*ensure*]
#   present | absent
#
# [*vhost*]
#   Required. Used to refer to a vhost. It must contain apache2::vhost resource name.
#
# [*location*]
#   URI searched to apply directive. Required
#
# [*directives*]
#   An array of directives in the form: ['directive1 value','directive2 value']
#
# [*order*]
#   Used to sort the Location block under the same vhost. Default: 0
#
# [*locationmatch*]
#   if true <LocationMatch> is used instead of <Location>. In this case location can be a regex Default: false
#
# === Examples
#
#   apache2::vhost {'www.example.com':
#     document_root => '/var/www/www.example.com'
#   }
#
#   apache2::location { 'root':
#     vhost      => 'www.example.com',
#     location   => '/',
#     directives =>  [
#       'AuthType Basic',
#       'AuthName "Area riservata"',
#       'AuthBasicProvider file',
#       'Require valid-user',
#       'AuthUserFile /var/www/www.example.com/.htusers',
#     ],
#   }
#
#
define apache2::location (
  $vhost,
  $location,
  $directives,
  $ensure         = present,
  $order          = '0',
  $locationmatch  = false
) {


  if !is_array($directives) {
    $array_directives = [$directives]
  }
  else {
    $array_directives = $directives
  }

  $ensure_fragment = $ensure? {
    'absent'  => $ensure,
    default   => present
  }

  # FIXME: il selettore nel blocco di una risorsa è segnato warn da puppet-lint
  # TODO: aggiungerei il check dei valori validi fuori dal blocco e userei il
  #       valore di $ensure direttamente nella ensure
  concat_fragment { "${vhost}+020-location-${order}.tmp":
    ensure  => $ensure_fragment,
    content => template('apache2/vhost/location.erb'),
  }

}
