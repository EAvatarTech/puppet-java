class java($version='present') {

  exec { 'enforce_apt_update':
    command => 'apt-get update',
    path => '/usr/bin'
  }
  
  
  apt::ppa { 'ppa:webupd8team/java': 
  }
  

  exec {
    'set-licence-selected':
      command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections';
 
    'set-licence-seen':
      command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections';
  
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
