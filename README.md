# cc_labor

## Aufgabe 3
### a)
Eine Skizze liegt im GitLab Ordner.
### b)
Praktisch wurde alles in aws umgesetzt wie auf der Skizze zu sehen und im folgendem Text näher beschrieben.
### c)
Die Instanz im APP Subnetz hat einen NGINX Webserver der auf Port 80 lauscht und über Http eine simple index- Seite liefert.
Um die Webseite von App zu erreichen, muss man sich bei der Instanz im DMZ über SSH verbinden und dann die APP-Instanz über Port 80 ansprechen. Als weitere Möglichkeit kann der Loadbalancer genutzt werden, welcher Zugriff auf die Security Group APPs hat, um auf das Subnetz in dem sich der NGINX Webserver befindet zugriff zu bekommen.
Das Packer Skript erstellt ein AMI auf Basis eines bereitgestellten Ubuntu Images. Zusätzlich werden über einen Shell Provisioner die aktuellen Sicherheitsupdates gewährleistet und nginx als webserver installiert. Ein File provisioner kopiert eine index.html Datei in das tmp Verzeichnis des ec2-Instance. Dies ist notwendig, da der temporäre provisioner user keine root Rechte besitzt. Im Anschluss verschiebt ein weiterer Shell Provisioner mit root Rechten die index.html Datei aus dem /tmp Verzeichnis in das nginx Verzeichnis, so dass sie als statische Website dargestellt werden kann.
### d)
Wir haben ein VPC in unserer Cloud erstellt.
In einem VPC lassen sich verschiedene Subnetze erstellen.
Dazu haben wir wie auf der Skizze gezeigt 3 Subnetze erstellt.
Das DMZ Subnetz ist direkt aus dem Internet erreichbar über die IPv4 Adresse der EC2 Instanz "DMZ"

Der SSH Schlüssel von der APP-Instanz ist auf der DMZ-Instanz gespeichert. Das ermöglicht die Verbindung zwischen den beiden Instanzen.
Genauso ist der SSH-Schlüssel von der DATA-Instanz auf der APP-Instanz um von dort aus zuzugreifen.

Das cloud-init.sh Skript installiert die aws cli auf der ec2 Instanz und attached und mounted im Anschluss eine bestehende EBS Storage Instanz als virtual disk. Voraussetzung für das Skript ist, dass die id der ebs-Instant bekannt ist. Die ec2-instance-id wird über die meta data generiert.

### e)
Zunächst lässt sich keine Instanz ohne öffentliche IP aus dem Internet erreichen.
Wir haben zusätzlich 3 verschiedene Security Groups erstellt (DMZ, APPs, Data) um die Zugriffe zwischen den Subnetzen zu regeln:
DMZ: von überall erreichbar (Bastion)
APPs: nur über SG1 (DMZ) und den Loadbalancer
Data: nur über SG2 (APPs) erreichbar (Ports: ssh, sql)
### f)
Wir haben einen Loadbalancer in unserem VPC angelegt. Über den Loadbalancer können wir Anfragen über verschiedene Ports regulieren.
Die sinnvollste Anwendung ist:
Den DMZ Server mit einem Loadbalancer zu ersetzen. Der Loadbalancer wird an seiner Stelle alle Http anfragen an den App Server leiten und die Index-Seite liefern. Die Instanz im DMZ dienst nur noch als Bastion.

Wir wollen aber gerne die 3 Subnetze mit den 3 EC2 Instanzen demonstrieren und haben daher den Loadbalancer mit dem DMZ Server verbunden, nur um zu zeigen,
das er evtl. verschieden Anfragen an verschiedenen Instanzen weiterleiten kann.
