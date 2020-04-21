# ALED Controller
Besteht aus: asd
## 1. NodeMCU 
genutz wird hier das Wled Framework

## 2.LED Strip

## 3.nodeRED
unter Debian auf einem Raspberry Pi

## 4.wlan AP
serverdienst für die kommunikation

## 5.flutter App

In der Flutter Application.
Können befehle an den LED Strip gesendet werden.
Diese ist möglich indem die App einen http request an das auf dem Raspberry laufende nodeRed sendet.
Das NodeRED kommuniziert mit dem Wled Framework auf dem NodeMCU.
Der NodeMCU empfängt seine befehle per MQTT.



Homescreen
IP Verbdingung eingeben
Port eingeben
Verbindung aufbauen
Wecker starten 
Sleep 
Effekt auswählen
