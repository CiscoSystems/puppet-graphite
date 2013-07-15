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
       name     => "gcc",
       ensure   => "installed",
    }
   
    package { "build-essential":
       name     => "build-essential",
       ensure   => "installed",
    }

    package { "python-twisted":
       name     => "python-twisted",
       ensure   => "installed",
    }

    package { "python-cairo":
       name     => "python-cairo",
       ensure   => 'installed',
    }

    package { "libapache2-mod-python":
       name     => "libapache2-mod-python",
       ensure   => 'installed',
    }

    package { "python-django":
       name     => "python-django",
       ensure   => 'installed',
    }

    package { "python-ldap":
       name     => "python-ldap",
       ensure   => 'installed',
    }

    package { "python-memcache":
       name     => "python-memcache",
       ensure   => 'installed',
    }

    package { "python-sqlite":
       name     => "python-sqlite",
       ensure   => 'installed',
    }

    package { "x11-apps":
       name     => "x11-apps",
       ensure   => 'installed',
    }

    package { "xfonts-base":
       name     => "xfonts-base",
       ensure   => 'installed',
    }

    package { "python-dev":
       name     => "python-dev",
       ensure   => 'installed',
    }

    package { "python-crypto":
       name     => "python-crypto",
       ensure   => 'installed',
    }

    package { "python-openssl":
       name     => "python-openssl",
       ensure   => 'installed',
    }

    package { "django-tagging":
       name     => "django-tagging",
       ensure   => 'installed',
       provider => 'pip',
    }
   
   package { "graphite-web":
       name     => "graphite-web",
       ensure   => 'installed',
       provider => 'pip',
    }
 
    package { "carbon":
       name     => "carbon",
       ensure   => 'installed',
       provider => 'pip',
       require  => [Package['python-cairo'], Package['libapache2-mod-python'], Package['python-django'], Package['python-ldap'], Package['python-memcache'], Package['python-sqlite'], Package['x11-apps'], Package['xfonts-base']]
    }

    package { "whisper":
       name     => "whisper",
       ensure   => 'installed',
       provider => 'pip',
       require  => [Package['python-cairo'], Package['libapache2-mod-python'], Package['python-django'], Package['python-ldap'], Package['python-memcache'], Package['python-sqlite'], Package['x11-apps'], Package['xfonts-base']]
    }

    file { '/opt/graphite/conf/carbon.conf':
        #source  => 'puppet:///modules/graphite/carbon.conf',
        owner   => 'root',
        group   => 'root',
        mode    => '644',
        require => Package['carbon'],
        content => template('graphite/carbon.conf.erb'),
    }


    file { '/opt/graphite/conf/storage-schemas.conf':
        source  => 'puppet:///modules/graphite/storage-schemas.conf',
        owner   => 'root',
        group   => 'root',
        mode    => '644',
        require => Package['whisper'],
    }

    file { '/opt/graphite/conf/graphite.wsgi':
        source  => 'puppet:///modules/graphite/graphite.wsgi',
        owner   => 'root',
        group   => 'root',
        mode    => '655',
        require => Package['graphite-web'],
    }

    file { '/opt/graphite/webapp/graphite/local_settings.py':
        source  => 'puppet:///modules/graphite/local_settings.py',
        owner   => 'root',
        group   => 'root',
        mode    => '655',
        require => Package['graphite-web'],
    }

    file { "/etc/httpd":
        ensure  => "directory",
}


    file { "/etc/apache2/sites-available/graphite":
        source  => 'puppet:///modules/graphite/graphite',
        owner   => 'root',
        group   => 'root',
        mode    => '755',
        require => Package['graphite-web'],
}

    file { "/etc/apache2/sites-enabled/graphite":
        ensure => link,
        target => "/etc/apache2/sites-available/graphite",
}


    file { "/etc/httpd/wsgi":
        ensure => "directory",
        require => File['/etc/httpd'],
}

    exec { "graphite-syncdb":
      command     => "python /opt/graphite/webapp/graphite/manage.py syncdb --noinput",
      logoutput => true,
      path => "/bin:/usr/bin:/sbin:/usr/sbin",
      require     => Package['graphite-web'],
    }

   
    file { "/opt/graphite/storage":
      ensure => directory,
      owner => "www-data",
      group => "www-data",
      mode => "755",
      require => Package['graphite-web']
    }

    file {"/opt/graphite/storage/log/webapp":
      ensure => directory,
      owner => "www-data",
      group => "www-data",
      mode  => "0755",
      require => Package['graphite-web']
    }

    file{"/opt/graphite/storage/graphite.db":
      ensure => present,
      owner  => "www-data",
      group  => "www-data",
      mode   => "0644",
      require => Package['graphite-web']
    }

    exec { "carbon-stop":
                command => "pkill -9 -f carbon-cache.py",
                path => "/bin:/usr/bin:/sbin:/usr/sbin",
                logoutput => true,
                onlyif => "pgrep -f carbon-cache.py", 
                notify => Exec["carbon-start"],
		require => Package["carbon"],
        }


    exec { "carbon-start":
                command => "python /opt/graphite/bin/carbon-cache.py start",
                path => "/bin:/usr/bin:/sbin:/usr/sbin",
                logoutput => true,
                unless => "pgrep -f carbon-cache.py",
		require => Package["carbon"],
        }

}
