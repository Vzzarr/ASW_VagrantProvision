class java {
 
 include apt

      apt::ppa { 'ppa:openjdk-r/ppa': 
        ensure => present,
      }

      exec { 'apt-update':
        command => '/usr/bin/apt-get update',
        require => [
          Apt::Ppa['ppa:openjdk-r/ppa']
        ],
      }

      package { 'openjdk-8-jdk':
        require  => [
          Exec['apt-update'],
          Apt::Ppa['ppa:openjdk-r/ppa'],
        ],
      } 
}
