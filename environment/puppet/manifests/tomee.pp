# update the (outdated) package list
exec { "update-package-list":
  command => "/usr/bin/sudo /usr/bin/apt-get update",
}

class tomee {


 file {"/opt/tomee-1.7.4":
    ensure => directory,
    recurse => true,
 } ->

 exec { "download-tomee" :
    command => "/usr/bin/wget http://apache.rediris.es/tomee/tomee-1.7.4/apache-tomee-1.7.4-webprofile.tar.gz -O /tmp/tomee-1.7.4.tar.gz",
    creates => "/tmp/tomee-1.7.4.tar.gz",
 } ->

 exec { "unpack-tomee" : 
    command => "/bin/tar -xzf /tmp/tomee-1.7.4.tar.gz -C /opt/tomee-1.7.4 --strip-components=1",
    creates => "/opt/tomee-1.7.4/bin",
 }

 service { "tomee" :
    provider => "init",
    ensure => running,
    start => "/usr/bin/sudo /opt/tomee-1.7.4/bin/startup.sh",
    stop => "/usr/bin/sudo /opt/tomee-1.7.4/bin/shutdown.sh",
    status => "",
    restart => "",
    hasstatus => false,
    hasrestart => false,
    require => Exec["unpack-tomee"],
  }

}

include tomee