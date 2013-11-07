class java($version='7u45-0~webupd8~0', $distribution='jdk') {

    if( !defined(Class['apt']) ) {
        class { 'apt': }
    }
  
    # Only exec if package 'python-software-properties' not installed.
    # Without this, 'apt::ppa' will fail.
    exec { 'enforce_apt_update':
        command => 'apt-get update',
        path => ['/usr/bin','/usr/sbin', '/bin', '/sbin'],
        onlyif => 'apt-cache policy python-software-properties | grep none',
    }
  
  
    apt::ppa { 'ppa:webupd8team/java': 
        require => Exec['enforce_apt_update'],
        notify => [Exec['set-licence-selected'], Exec['set-licence-seen']],
    }
  
    exec { 'set-licence-selected':
        command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections',
        refreshonly => true,
    }

    exec {'set-licence-seen':
        command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections',
        refreshonly => true,    
    }
  
    package { 'oracle-java7-installer':
        ensure => "${version}",
        require => Apt::Ppa['ppa:webupd8team/java'], 
    } 

    file { '/etc/profile.d/java.sh':
        ensure => present,
        source => "puppet:///modules/java/java.sh",
        owner => "root",
        group => "root",
        mode => 644,
        require => Package['oracle-java7-installer'],
    }

}
