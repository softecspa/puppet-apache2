# == Define apache2::enmod
#
# Manage apache2 modules
#
# === Example usage
#
#   apache2::enmod { 'rewrite': }
#
# === TODO
#  * rinominare in mod e permettere anche la rimozione
#  * prevedere la necessita' di un pacchetto libapache2-mod-$name
#
define apache2::enmod(
  $modulename = ''
) {

  include apache2

  $module = $modulename ? {
    ''      => $name,
    default => $modulename
  }

  include apache2::params

  $modspath = "${apache2::params::apache2dir}/mods-enabled"

  exec { "apache2-enmod-$module":
    command         => "/usr/sbin/a2enmod ${module} || a2enmod mod_${module}",
    onlyif          => ["/usr/bin/test -z \"`ls -1 $modspath | grep ${module}`\""],
    require         => [ Package['apache2'], Package['apache2-utils'] ],
    before          => Exec['apache2-reload']
  }
}
