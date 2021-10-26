# cc_labor

Wir haben bei der Lösung zu Aufgabe 3 ein VPC in unserer Cloud erstellt.
In einem VPC lassen sich verschiedene Subnetze erstellen
wir haben wie auf der Skizze beschrieben 3 Subnetze erstellt jeweils mit ca. 251 Adressen
Das DMZ Subnetz ist direkt aus dem Internet erreichbar über die ipv4 Adresse einer EC2 Instanz, die er hostet
Der App Server hat einen NGINX Webserver der auf Port 80 lauscht und über Http eine simple index- Seite liefert.
Er ist außerdem über SSH aus dem Internet erreichbar
Um die Webseite von App zu erreichen, muss man sich bei DMZ über SSH verbinden und dann den App-Server über Port 80 ansprechen.

Der SSH Schlüssel vom App Server ist auf dem DMZ Server gespeichert. Das ermöglicht die Verbindung zwischen den beiden Instanzen.
Das gleiche Prinzip ist mit der Data EC2 Instanz.

Wir haben 3 verschiedene Security Groups erstellt (DMZ, App, Data), um die Zugriffe zwischen den Subnetzen zu regeln
SG1: von überall erreichbar
SG2: nur über SG1 (dmz) erreichbar (ssh)
SG3: nur über SG2 (App) erreichbar (ssh) evtl. auch sql

Wir haben eine Instanz Loadbalancer in unserem VPC gestartet. Über den Loadbalancer können wir Anfragen über verschiedene Ports regulieren.
Die sinnvollste Anwendung ist:
Den DMZ Server mit einem Loadbalancer zu ersetzen. Der Loadbalancer wird an seiner Stelle alle Http anfragen an den App Server leiten und die Index-Seite liefern.

Wir wollen aber gerne die 3 Subnetzen mit den 3 EC2 Instanzen demonstrieren und haben daher den Loadbalancer mit dem DMZ Server verbunden, nur um zu zeigen,
das er evtl. verschieden Anfragen an verschiedenen Instanzen weiterleiten kann
