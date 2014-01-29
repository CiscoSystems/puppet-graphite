#
# Class: graphite
#
# Manages graphite.
# Include it to install graphite.
#
# Usage:
# include graphite
#
class graphite ( $graphitehost ) {
  package { 'x11-apps':
    ensure => installed,
  }

  package { 'graphite-web':
    ensure => installed,
  }

  package { 'graphite-carbon':
    ensure => installed,
  }

  package { 'python-whisper':
    ensure => installed,
  }

  file { '/etc/carbon/carbon.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['graphite-carbon'],
    content => template('graphite/carbon.conf.erb'),
  }

  file { '/etc/carbon/storage-schemas.conf':
    source  => 'puppet:///modules/graphite/storage-schemas.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['graphite-carbon'],
  }

  file { '/etc/default/graphite-carbon':
    source  => 'puppet:///modules/graphite/graphite-carbon',
    owner   => 'root',
    group   => 'root',
    mode    => '0655',
    require => Package['graphite-carbon'],
  }

  file { '/usr/share/graphite-web/graphite.wsgi':
    source  => 'puppet:///modules/graphite/graphite.wsgi',
    owner   => 'root',
    group   => 'root',
    mode    => '0655',
    require => Package['graphite-web'],
  }

  file { '/etc/httpd':
    ensure => directory,
  }

  file { '/etc/apache2/sites-available/graphite':
    source  => 'puppet:///modules/graphite/graphite',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['graphite-web'],
  }

  file { '/etc/apache2/sites-enabled/50-graphite.conf':
    ensure => link,
    target => '/etc/apache2/sites-available/graphite',
  }

  file { '/etc/httpd/wsgi':
    ensure  => directory,
    require => File['/etc/httpd'],
  }

  file { '/var/lib/graphite/graphite.db':
    ensure  => present,
    owner   => '_graphite',
    group   => '_graphite',
    mode    => '0644',
    require => Package['graphite-web']
  }

  exec { 'graphite-syncdb':
    command   => 'graphite-manage syncdb --noinput',
    logoutput => true,
    path      => '/bin:/usr/bin:/sbin:/usr/sbin',
    require   => Package['graphite-web'],
  }

  service {'carbon-cache':
    ensure  => 'running',
    enable  => true,
    require => Package['graphite-carbon']
  }
}
