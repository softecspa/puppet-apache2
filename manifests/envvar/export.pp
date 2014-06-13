define apache2::envvar::export (
  $var_name = '',
  $value    = '',
) {

  if !defined(File['/etc/apache2/envvars.d']) {
    file {'/etc/apache2/envvars.d':
      ensure  => directory,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
    }
  }

  if !defined(Softec::Lib::Line['apache2-envvars-include']) {

    exec {'delete_envvarsd':
      command => 'sed -e "s/^\.\ \/etc\/apache2\/envvars\.d\/\*$//" -i /etc/apache2/envvars',
      onlyif  => 'egrep "^\.\ \/etc\/apache2\/envvars\.d\/\*$" /etc/apache2/envvars',
      path    => $::path
    }

    softec::lib::line { 'apache2-envvars-include':
      ensure  => present,
      file    => '/etc/apache2/envvars',
      line    => 'for f in /etc/apache2/envvars.d/*; do . $f; done',
      notify  => Exec['email-restart-apache'],
      require => File['/etc/apache2/envvars.d'],
    }
  }

  $var = $var_name? {
    ''      => $name,
    default => $var_name,
  }

  file { "/etc/apache2/envvars.d/$var":
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => inline_template("export <%= @var -%><% if @value != '' -%>=<%= @value -%><% end %>"),
    notify  => Exec['email-restart-apache'],
    require => File['/etc/apache2/envvars.d'],
  }

}
