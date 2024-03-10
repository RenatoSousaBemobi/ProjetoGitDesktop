#!/bin/bash

#Consulta às Tabelas CDR para levantamentos com milhões de MSISDNS

for table in $(cat tabelascdr2.txt); 
	do mysql -h10.8.129.108 -P3306 -udbadm -pFEqrRsgGW8kbmBUINR2a -e"SELECT distinct(concat(DDD,Num)) as MSISDN FROM esync_cdr.$table where IdSms in ('18N') AND Status regexp '...S.....';" -N -s >> MSISDNs_2x_3x_7x_8x_9x_18N.txt
	done &
