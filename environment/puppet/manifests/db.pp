class { 'postgresql::server':
	postgres_password          => 'asd',
}

postgresql::server::db { 'mydatabasename':
  user     => 'mydatabaseuser',
  password => postgresql_password('mydatabaseuser', 'mypassword'),
}