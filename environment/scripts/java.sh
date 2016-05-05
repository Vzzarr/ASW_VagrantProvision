#!/bin/bash

sudo mkdir /opt/java
cd /opt/java
sudo wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.tar.gz"
sudo tar -zxvf jdk-8u45-linux-x64.tar.gz

cd jdk1.8.0_45/
sudo update-alternatives --install /usr/bin/java java /opt/java/jdk1.8.0_45/bin/java 100  
sudo update-alternatives --config java

sudo update-alternatives --install /usr/bin/javac javac /opt/java/jdk1.8.0_45/bin/javac 100
sudo update-alternatives --config javac

sudo update-alternatives --install /usr/bin/jar jar /opt/java/jdk1.8.0_45/bin/jar 100
sudo update-alternatives --config jar

export JAVA_HOME=/opt/java/jdk1.8.0_45/	
export JRE_HOME=/opt/java/jdk1.8.0._45/jre 	
export PATH=$PATH:/opt/java/jdk1.8.0_45/bin:/opt/java/jdk1.8.0_45/jre/bin
