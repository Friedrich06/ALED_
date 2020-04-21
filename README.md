# ALED Controller
Es soll die Möglichkeit zur Steuerung eines RGB-LED-Strip geschaffen werden. Die Ansteuerung soll zum einen die Möglichkeit zur Auswahl einer Farbe zulassen und zum anderen unterschiedliche Ab- und Auf-Dimmverläufe anbieten. Diese sollen die Möglichkeit schaffen mit einer Lichtuntermalung einzuschlafen bzw. aufzuwachen und die Farben und Farbverläufe so variabel seiner Stimmung anzupassen.

Verwendete Hardware:

Raspberry Pi: 
  Auf diesem Läuft NodeRED.
  
ESP8266:
  Auf diesem Läuft NodeMCU mit dem WLED Frameswork.
  
  
WS2812B:
  LED Strip

## 1. NodeMCU/ESP8266 
Ein vorkonfiguriertes WLED Paket finden sie unter config_esp8266.
Weitere Infos fiden sie unter:
https://github.com/Aircoookie/WLED/wiki
## 2.Raspberry Pi
Die verwendeten  NodeRED Flow finden sie unter config_nodeRED.

## 3.Raspap (optional)
Zur einfachen verwaltung der WLAN Schnitstellen des Raspberry wurde ein Raspap Server verwendet.
Weitere Infos fiden sie unter:
https://github.com/billz/raspap-webgui


