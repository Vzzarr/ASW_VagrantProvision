node 'web' {
	include apache
}
node 'db' {
	include postgres
}
exec { 'apt-get update':
	command => '/usr/bin/apt-get update'
}
class apache {
	package { 'apache2':
		ensure => present,
		require => Exec['apt-get update']
	}
	service { 'apache2':
		require => Package['apache2'],
		ensure => running,
		enable => true,
	}
	file { '/var/www':
		require => Package['apache2'],
		target => '/vagrant/www',
		ensure => link,
		force => true
	}
}
class postgres {
	package { 'postgresql':
		ensure => present,
		require => Exec['apt-get update']
	}
	service { 'postgresql':
		require => Package['postgresql'],
		ensure => running,
		enable => true,
	}
	file { '/var/www':
		require => Package['postgresql'],
		target => '/vagrant/www',
		ensure => link,
		force => true
	}
}

