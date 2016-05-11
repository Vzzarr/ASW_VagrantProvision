# create a new run stage to ensure certain modules are included first
stage { 'pre':
  before => Stage['main']
}

# set defaults for file ownership/permissions
File {
  owner => 'root',
  group => 'root',
  mode  => '0644',
}

node 'web' {
    include java,tomee
    Class['java'] -> Class['tomee']
}


 node 'db' {

	class { 'postgresql::server':
 	   listen_addresses           => '*',
       postgres_password          => 'postgres',}

  	postgresql::server::db { 'music':
  		user     => 'post',
  		password => postgresql_password('post', 'post'),}

  	postgresql::server::pg_hba_rule { 'allow application network to access database':
  		description => "Open up PostgreSQL for access from 10.11.1.100/32",
  		type        => 'host',
  		database    => 'all',
  		user        => 'all',
  		address     => '10.11.1.100/32',
  		auth_method => 'md5',
}	
 }



