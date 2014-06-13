define apache2::envvar::command (
  $filename,
  $command = '',
) {
  $command_name = $command?{
    ''      => $name,
    default => $command,
  }

  if !defined(File['/etc/apache2/envvars.d']) {
    file {'/etc/apache2/envvars.d':
      ensure  => directory,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
    }
  }

  if !defined(Softec::Lib::Line['apache2-envvars-include']) {

    #TODO: rimuovere, serve solo a togliere la vecchia riga
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

  file {"/etc/apache2/envvars.d/$filename":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $command,
    notify  => Exec['email-restart-apache'],
    require => File['/etc/apache2/envvars.d'],
  }
}
