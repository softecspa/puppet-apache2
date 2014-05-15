define apache2::htaccess_export (
  $user,
  $hash,
  $filepath = '/var/www/.htpasswd.users'
) {

  if !defined(Concat::Fragment["${user}-htaccess"]) {
    concat::fragment{ "${user}-htaccess":
      target  => $filepath,
      order   => 2,
      content => "${user}:${hash}\n",
    }
  }

}
