#!/bin/bash

# USB-RLY02 Network Monitor
# Copyright (C) 2014  Eugenio Bonifacio
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

DATE=$(date +"%d-%m-%Y %T")
CONTROLLER="rly02.py"
FILE="monitor.dat"
HOSTS="http://www.google.com http://192.168.1.14"
#HOSTS="http://www.google.com http://www.repubblica.it"
RETRIES=`cat $FILE`
MAX_RETRIES=2

echo $DATE

# Controllo esistenza del file
test -f $FILE
if [ $? -ne 0 ]; then
	echo "File non esistente, creazione..."
	touch $FILE
	echo "Creato"
fi

# Controllo contenuto numerico del file
egrep -e "^([0-9]+)" $FILE &> /dev/null

# Se non ha contenuto numerico lo inizializzo a zero
if [ $? -ne 0 ]; then
	echo "Inizializzazione file"
	echo 0 > $FILE
fi

echo "Tentativi falliti in precedenza $RETRIES"

MAX_REACHED=0
if [ $RETRIES -ge $MAX_RETRIES ]; then
	echo "Il router è stato spento"
	MAX_REACHED=1

	echo "Invio email..."
	echo "Il router è stato spento" | mail -s "Monitor rete internet" root
fi

# Controllo gli host
FAILED=0
for HOST in $HOSTS
do
	echo "Controllo '$HOST'..."

	wget -q --tries=10 --timeout=20 -O - $HOST &> /dev/null
	if [[ $? -eq 0 ]]; then
	        echo "Online"
	else
		echo "Offline"
		FAILED=$(( $FAILED+1 ))
	fi	
done

# Se ci sono stati dei fallimenti, incremento i tentativi
if [ $FAILED -gt 0 ]; then
	echo "Numero di host che non hanno risposto: $FAILED"

	RETRIES=$(( $RETRIES+1 ))
	
	if [ $MAX_REACHED -eq 0 ] && [ $RETRIES -ge $MAX_RETRIES ]; then
		echo "Spegnimento Router"
		
		if [ -f $CONTROLLER ]; then
		  echo "Spento"
		  python $CONTROLLER -r 1 -a on
		  sleep 60
		  echo "Acceso"
		  python $CONTROLLER -r 1 -a off
		else
		  echo "Controller non trovato"
		fi
		#RETRIES=0 non lo azzero per utilizzarlo all'inizio dello script per verificare una situazione successiva allo spegnimento
	fi
else
	echo "Rete accessibile"
	RETRIES=0
	MAX_REACHED=0
fi

echo $RETRIES > $FILE

echo "Tentativi totali falliti $RETRIES"
