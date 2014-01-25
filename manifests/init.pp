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

    package { "python-django-tagging":
       ensure   => 'installed',
       name     => "python-django-tagging",
    }
   
   package { "graphite-web":
       ensure   => 'installed',
       name     => "graphite-web",
    }
 
    package { "graphite-carbon":
       ensure   => 'installed',
       name     => "graphite-carbon",
       require  => [Package['python-cairo'], Package['libapache2-mod-python'], Package['python-django'], Package['python-ldap'], Package['python-memcache'], Package['python-sqlite'], Package['x11-apps'], Package['xfonts-base']]
    }

    package { "python-whisper":
       ensure   => 'installed',
       name     => "python-whisper",
       require  => [Package['python-cairo'], Package['libapache2-mod-python'], Package['python-django'], Package['python-ldap'], Package['python-memcache'], Package['python-sqlite'], Package['x11-apps'], Package['xfonts-base']]
    }

    file { '/etc/carbon/carbon.conf':
        #source  => 'puppet:///modules/graphite/carbon.conf',
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

    file { "/etc/apache2/sites-enabled/50-graphite.conf":
        ensure => link,
        target => "/etc/apache2/sites-available/graphite",
}


    file { "/etc/httpd/wsgi":
        ensure  => "directory",
        require => File['/etc/httpd'],
    }

    file { "/var/lib/graphite/graphite.db":
        ensure => 'present',
        owner => '_graphite',
        group => '_graphite',
        mode  => '0644',
        require => Package['graphite-web']
    }

    exec { "graphite-syncdb":
      command   => "graphite-manage syncdb --noinput",
      logoutput => true,
      path      => "/bin:/usr/bin:/sbin:/usr/sbin",
      require   => Package['graphite-web'],
    }

    service {'carbon-cache':
      ensure  => 'running',
      enable  => true,
      require => Package['graphite-carbon']
    }

}
