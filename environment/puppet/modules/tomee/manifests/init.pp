
# exec { "update-package-list":
#  command => "/usr/bin/sudo /usr/bin/apt-get update",
# }
class tomee {


 file {"/opt/tomee-1.7.4":
    ensure => directory,
    recurse => true,
 } ->

 exec { "download-tomee" :
    command => "/usr/bin/sudo /usr/bin/wget http://apache.rediris.es/tomee/tomee-1.7.4/apache-tomee-1.7.4-webprofile.tar.gz -O /tmp/tomee-1.7.4.tar.gz",
    creates => "/tmp/tomee-1.7.4.tar.gz",
 } ->

 exec { "unpack-tomee" : 
    command => "/usr/bin/sudo /bin/tar -xzf /tmp/tomee-1.7.4.tar.gz -C /opt/tomee-1.7.4 --strip-components=1",
    creates => "/opt/tomee-1.7.4/bin",
 }->

 exec { "driver-postgres":
    command => "/usr/bin/sudo /bin/cp /home/vagrant/project/postgresql-9.4.1208.jre6.jar /opt/tomee-1.7.4/lib/",
} ->

 exec { "file-.war":
    command => "/usr/bin/sudo /bin/cp /home/vagrant/project/ProgettoASW.war /opt/tomee-1.7.4/webapps/",
} ->

 exec { "tomee.xml":
    command => "/usr/bin/sudo /bin/cp /home/vagrant/project/tomee.xml /opt/tomee-1.7.4/conf/",
} ->

exec { "start tomcat":
    command => "/usr/bin/sudo /bin/sh /opt/tomee-1.7.4/bin/startup.sh"
} ->

exec { "1 tomee start script":
    command => "/usr/bin/sudo /bin/cp /home/vagrant/project/tomcat /etc/init.d",
} ->

exec { "2 tomee start script":
    command => "/usr/bin/sudo chmod 755 /etc/init.d/tomcat",
} ->

exec { "3 tomee start script":
    command => "/usr/bin/sudo update-rc.d tomcat defaults",
} 



 service { "tomee" :
    provider => "init",
    ensure => running,
    start => "/usr/bin/sudo /bin/sh /opt/tomee-1.7.4/bin/startup.sh",
    stop => "/usr/bin/sudo  /bin/sh /opt/tomee-1.7.4/bin/shutdown.sh",
    status => "",
    restart => "",
    hasstatus => false,
    hasrestart => false,
    require => Exec["unpack-tomee"],
  }
}