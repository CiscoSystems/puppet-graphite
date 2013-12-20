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
    include pip

    package { "gcc":
       ensure   => "installed",
       name     => "gcc",
    }
   
    package { "build-essential":
       ensure   => "installed",
       name     => "build-essential",
    }

    if !defined(Package['python-twisted']){
       package { "python-twisted":
          ensure   => "installed",
          name     => "python-twisted",
       }
    }

    package { "python-cairo":
       ensure   => 'installed',
       name     => "python-cairo",
    }

    package { "libapache2-mod-python":
       ensure   => 'installed',
       name     => "libapache2-mod-python",
    }

    package { "python-django":
       ensure   => 'installed',
       name     => "python-django",
    }

    package { "python-ldap":
       ensure   => 'installed',
       name     => "python-ldap",
    }

    package { "python-memcache":
       ensure   => 'installed',
       name     => "python-memcache",
    }

    package { "python-sqlite":
       ensure   => 'installed',
       name     => "python-sqlite",
    }

    package { "x11-apps":
       ensure   => 'installed',
       name     => "x11-apps",
    }

    package { "xfonts-base":
       ensure   => 'installed',
       name     => "xfonts-base",
    }

    package { "python-dev":
       ensure   => 'installed',
       name     => "python-dev",
    }

    package { "python-crypto":
       ensure   => 'installed',
       name     => "python-crypto",
    }

    package { "python-openssl":
       ensure   => 'installed',
       name     => "python-openssl",
    }

    package { "django-tagging":
       ensure   => 'installed',
       name     => "django-tagging",
       provider => 'pip',
    }
   
   package { "graphite-web":
       ensure   => 'installed',
       name     => "graphite-web",
       provider => 'pip',
    }
 
    package { "carbon":
       ensure   => 'installed',
       name     => "carbon",
       provider => 'pip',
       require  => [Package['python-cairo'], Package['libapache2-mod-python'], Package['python-django'], Package['python-ldap'], Package['python-memcache'], Package['python-sqlite'], Package['x11-apps'], Package['xfonts-base']]
    }

    package { "whisper":
       ensure   => 'installed',
       name     => "whisper",
       provider => 'pip',
       require  => [Package['python-cairo'], Package['libapache2-mod-python'], Package['python-django'], Package['python-ldap'], Package['python-memcache'], Package['python-sqlite'], Package['x11-apps'], Package['xfonts-base']]
    }

    file { '/opt/graphite/conf/carbon.conf':
        #source  => 'puppet:///modules/graphite/carbon.conf',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['carbon'],
        content => template('graphite/carbon.conf.erb'),
    }


    file { '/opt/graphite/conf/storage-schemas.conf':
        source  => 'puppet:///modules/graphite/storage-schemas.conf',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['whisper'],
    }

    file { '/opt/graphite/conf/graphite.wsgi':
        source  => 'puppet:///modules/graphite/graphite.wsgi',
        owner   => 'root',
        group   => 'root',
        mode    => '0655',
        require => Package['graphite-web'],
    }

    file { '/opt/graphite/webapp/graphite/local_settings.py':
        source  => 'puppet:///modules/graphite/local_settings.py',
        owner   => 'root',
        group   => 'root',
        mode    => '0655',
        require => Package['graphite-web'],
    }

    file { "/etc/httpd":
        ensure  => "directory",
}


    file { "/etc/apache2/sites-available/graphite":
        source  => 'puppet:///modules/graphite/graphite',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => Package['graphite-web'],
}

    file { "/etc/apache2/sites-enabled/graphite":
        ensure => link,
        target => "/etc/apache2/sites-available/graphite",
}


    file { "/etc/httpd/wsgi":
        ensure  => "directory",
        require => File['/etc/httpd'],
}

    exec { "graphite-syncdb":
      command   => "python /opt/graphite/webapp/graphite/manage.py syncdb --noinput",
      logoutput => true,
      path      => "/bin:/usr/bin:/sbin:/usr/sbin",
      require   => Package['graphite-web'],
    }

   
    file { "/opt/graphite/storage":
      ensure  => directory,
      owner   => "www-data",
      group   => "www-data",
      mode    => "0755",
      require => Package['graphite-web']
    }

    file {'/opt/graphite/storage/log/carbon-cache':
      ensure  => directory,
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0755',
      require => Package['carbon']
    }

    file {'/opt/graphite/storage/log/carbon-cache/carbon-cache-a':
      ensure  => directory,
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0755',
      require => File['/opt/graphite/storage/log/carbon-cache']
    }

    file {'/opt/graphite/storage/log/webapp':
      ensure  => directory,
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0755',
      require => Package['graphite-web']
    }

    file{'/opt/graphite/storage/graphite.db':
      ensure  => present,
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0644',
      require => Package['graphite-web']
    }

    file{'/etc/init.d/carbon-cache':
      ensure  => present,
      source  => 'puppet:///modules/graphite/carbon-cache.init',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => Package['carbon']
    }

    exec {'carbon-service':
      command   => 'update-rc.d /etc/init.d/carbon-cache defaults',
      path      => '/bin:/usr/bin:/sbin:/usr/sbin',
      logoutput => true,
      onlyif    => 'pgrep -f /etc/init.d/carbon-cache',
      require   => [Package['carbon'], File['/etc/init.d/carbon-cache']]
    }

    service {'carbon-cache':
      ensure  => 'running',
      enable  => true,
      require => [Package['carbon'], File['/etc/init.d/carbon-cache']]
    }

    file {'/etc/logrotate.d/carbon_rotate':
      source  => 'puppet:///modules/graphite/carbon-logrotate.erb',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => Package['carbon']
    }

}
