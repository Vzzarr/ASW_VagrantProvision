# Progetto di Architetture dei sistemi software
#### Tabella dei contenuti

1. [Descrizione del progetto - Cosa è in grado di fare?](#obiettivi)
2. [Applicazione](#applicazione)
    * [Descrizione](#applicazione)
    * [Tecnologie utilizzate](#applicazione)
3. [Provisioning](#provisioning)
    * [Apache TomEE](#apache-tomee)
      * [Avvio Automatico](#avvio-automatico)
    * [Postgres](#postgres)
      * [Setup](#setup)
      * [Creazione di un database](#creazione-di-un-database)
4. [Installazione](#installazione)
5. [Comandi utili](#comandi-utili)
6. [Todo](#todo)
7. [Realizzatori](#realizzatori)

### Obiettivi

Il progetto è stato realizzato nell'ambito del corso di Architetture dei Sistemi Software. La prima parte del progetto ha previsto tre obiettivi principali: 

  - la realizzazione di una semplice applicazione
  - la creazione di un ambiente per mandare in esecuzione l'applicazione
  - la possibilità di accedere all'applicazione, in esecuzione su una delle due macchine, dal proprio browser 
 
Attraverso l'utilizzo di [Vagrant][vagrant] è stato quindi realizzato un ambiente  costituito da due macchine virtuali.  La prima delle due macchine virtuali svolge la funzione di server e su di essa è installato [Apache TomEE][tomee], mentre sulla seconda è installato [Postgres][postgres].

### Applicazione

L'applicazione, seguendo le specifiche, è minimale. Nella realizzazione è stato seguito il pattern model-view-controller e si tratta essenzialmente di un gestore di cantanti e canzoni. Fornisce possibilità di inserimento e visualizzazione di entrambe le entità coinvolte. Il codice dell'applicazione è in Java ed è stato fatto uso di diversi framework e tecnologie:
* [JPA] - Per la gestione della persistenza
* [JSF] - Per l'interfaccia utente lato server
* [JSP] - Per la programmazione web

N.B.: Per la sua esecuzione è richiesta l'installazione di JAVA 8

### Provisioning
Per la parte di provisioning si è fatto uso di [Puppet][puppet]. L'obiettivo principale del progetto è stato infatti quello di lanciare in esecuzione automatica l'intero ambiente attraverso un unico comando. 
Gli obiettivi del provisioning hanno previsto l'installazione delle seguenti componenti:
- sulla macchina "www":
1. Apache-tomee-1.7.4-webprofile
2. Java 8
3. Il driver postgresql-9.4.1208.jre6.jar
- sulla macchina "db":
1. Postgres

   
Nel Vagrant file sono quindi state specificate le condizioni di provisioning:

```sh
config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "puppet/manifests"
        puppet.manifest_file = "site.pp"
        puppet.module_path = "puppet/modules"
```
All'interno della cartella environment è stata quindi definita la seguente struttura :

```
+-- Vagrantfile
+-- _Puppet
|   +--_manifest
|          +-- site.pp
|   +-- _modules
|          +-- _java
|                +-- _manifest
|                       +-- init.pp
|          +-- _tomee
|                +-- _manifest
|                       +-- init.pp
```
Si sono quindi utilizzati moduli già disponibili su PuppetForge per l'installazione di Java e Postgres, mentre per TomEE non si è fatto uso di nessun modulo predefinito.
Si è preferito procedere con l'installazione dei moduli direttamente dal Vagrantfile: una scelta progettuale dettata principalmente da esigenze di testing. Per esempio nel file init.pp di Java è richiesto l'uso di apt, reso disponibile da:
```sh
config.vm.provision :shell do |shell|
    shell.inline = "mkdir -p /etc/puppet/modules;
                    puppet module install puppetlabs/apt"
```

#### Apache TomEE

Per facilità d'uso il driver di postgres, l'applicazione e il file tomee.xml (necessario per le specifiche di comunicazione remota con il database) sono state inserite nella cartella condivisa project. Sono state quindi specificate, nel file tomee.pp, le operazioni necessarie allo spostamento nei file nelle corrette cartelle:
```puppet
 exec { "driver-postgres":
    command => "/usr/bin/sudo /bin/cp  /home/vagrant/project/postgresql-9.4.1208.jre6.jar /opt/tomee-1.7.4/lib/",
} ->

 exec { "file-.war":
    command => "/usr/bin/sudo /bin/cp /home/vagrant/project/ProgettoASW.war /opt/tomee-1.7.4/webapps/",
} ->

 exec { "tomee.xml":
    command => "/usr/bin/sudo /bin/cp /home/vagrant/project/tomee.xml /opt/tomee-1.7.4/conf/",
} ->
```

##### Avvio automatico
Tomcat si avvia in automatico dopo l'installazione. È stato però necessario fare in modo che ripartisse in automatico al boot della macchina. Per fare questo è stato opportuno aggiungere un file tomcat nella cartella /etc/init.d. Il contenuto del file tomcat è:
```sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin

start() {
sudo sh /opt/tomee-1.7.4/bin/startup.sh
}

stop() {
sudo sh /opt/tomee-1.7.4/bin/shutdown.sh
}

case $1 in 
  start) $1;;
  restart) stop; start;;
  *) echo "Run as $0 <start|stop|restart>"; exit 1;;
esac

```
Inoltre è necessario eseguire i seguenti comandi dal terminale al fine di modificare il permesso e aggiungere automaticamente il corretto symlink


```sh
chmod 755 /etc/init.d/tomcat
update-rc.d tomcat defaults
```
#### Postgres

##### Setup

Alla configurazione base di postgres, nel file db.pp, sono state aggiunte alcune specifiche per rendere possibile la connessione con la macchina "www". In questa configurazione Postgres non impone vincoli sugli indirizzi d'ascolto, nè su quelli che possono richiedere una connessione.

```puppet
class { 'postgresql::server':
  ip_mask_allow_all_users    => '0.0.0.0/0',
  listen_addresses           => '*',
  postgres_password          => 'postgres',}
  ```
 Ciò che avviene a seguito di queste istruzioni è la modifica dei file postgres.conf e pg_hba.conf.
 
##### Creazione di un database
  
 Dopo aver specificato questi parametri è possibile verificare  le operazioni attraverso il comando:
 ```
$ psql -h 127.0.0.1 -p 5432 -U postgres -W
```
a seguito del quale verrà chiesto di inserire la password.
È stato inoltre opportuno creare un db music, attraverso cui l'applicazione sulla VM "www" può svolgere le proprie operazioni.
  ```puppet
postgresql::server::db { 'music':
  user     => 'post',
  password => postgresql_password('post', 'post'),}
```
È possibile connettersi al database appena creato per mostrare i dati presenti, attraverso la sequenza di comandi:
  ```sh
$ psql -h 127.0.0.1 -p 5432 -U postgres -W
$ \connect music
$ SELECT * FROM artist;
```


### Installazione

Per eseguire l'applicazione è necessaria l'installazione di Vagrant e VirtualBox. Una volta installati i due software è sufficiente scaricare il progetto,

```sh
$ git clone https://github.com/Vzzarr/ASW_VagrantProvision.git
```
e dopo essersi posizionati nella cartella environment dare il comando:
```sh
$ vagrant up
```
Questa operazione può richiedere diversi minuti.
A questo punto per utilizzare l'applicazione è sufficiente connettersi alla pagina
```sh
$ localhost:2212/ProgettoASW
```
### Comandi utili
Nelle operazioni di testing possono risultare utili i seguenti comandi:
* In generale
    * nella modifica di file di testo attraverso vim spesso ci si trova a modificare file di tipo read-only, è utile quindi il comando: " :w! sudo tee % "
    
* Sulla macchina www
```sh
$ ps aux | grep tomee
```
* Sulla macchina db
    * per connettersi a Postgres
    * per visualizzare la porta d'ascolto 
```sh
$ psql -h 127.0.0.1 -p 5432 -U postgres -W
$ sudo netstat -tulpn | grep postgres
```

### ToDo
* L'avvio di Tomee è manuale, è necessario posizionarsi in /tomee/bin ed eseguire ./startup.sh. Si vuole quindi automatizzare anche questo processo. [Risolto]
* Tomee si deve avviare al boot della macchina. [Risolto]
* La cartella files di Java serve?
* Migliorare i nomi dei file.
* Il download di Java8 è lento. Si vuole ridurre la quantità dei file da scaricare, limitandosi alle componenti essenziali. Eventualmente valutare la modifica dell'applicazione, individuando le istruzioni che richiedono l'utilizzo di Java8 (Java 7 dovrebbe andar bene).
* Non funziona il link tra la tabella dei contenuti e  le varie sezioni di questo file. [Risolto]
* Creare un file .gitignore che impedisca il caricamento delle configurazioni delle VM su Git. [Risolto]
* Migliorare interfaccia applicazione, magari usando Bootstrap



### Realizzatori

 - Davinder Kumar
 - Mattia Iodice
 - Jhohattan Loza
 - Nicholas Tucci
 
[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)



   [vagrant]: <https://www.vagrantup.com>
   [tomee]: <http://tomee.apache.org/index.html>
   [postgres]: <http://www.postgresql.org>
   [JPA]: <https://it.wikipedia.org/wiki/Java_Persistence_API>
   [JSF]: <https://it.wikipedia.org/wiki/Java_Server_Faces>
   [JSP]: <https://it.wikipedia.org/wiki/JavaServer_Pages>
   [puppet]: <https://puppet.com>



