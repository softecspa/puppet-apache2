# == define apache2::override
#
# This define manage apache2 AllowOverride directive. It push a file in /etc/apache2/conf.d/
# This define is a wrapper of apache2::paramfile. See apache2::paramfile doc for more specific tuning
#
# === Parameters
#
# [*directory*]
#   restrict influence on a specified directory. Default: /
#
# [*allow*]
#   Value for AllowOverride directive. Default: None
#
# [*filename*]
#   name of file pushed in /etc/apache2/conf.d. If isn't set, <name> will be used
#
define apache2::override (
  $directory  = '/',
  $allow      = 'None',
  $filename   = ''
) {

  $file = $filename? {
    ''      => $name,
    default => $filename,
  }

  apache2::paramfile { $file :
    params    => {  'AllowOverride' => $allow },
    directory => $directory,
  }
}
