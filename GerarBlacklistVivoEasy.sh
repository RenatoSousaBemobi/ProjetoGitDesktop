#!/bin/bash

#Este script tem por objetivo obter a lista de MSISDNs da Blacklist VivoEasy

#Obter blacklist
echo ""
echo "Obtendo a Blacklist..."
mysql -h10.43.1.100 -P3306 -udbadm -pFEqrRsgGW8kbmBUINR2a -e"SELECT CONCAT(DDDA,NUMA) as MSISDN FROM assinaturarecadovivo.assinaturas where Estado = 3 and CodPacote = 6;" -N -s >> Base_Bemobi_SP.txt
mysql -h10.8.129.102 -P3306 -udbadm -pFEqrRsgGW8kbmBUINR2a -e"SELECT CONCAT(DDDA,NUMA) as MSISDN FROM assinaturarecadovivo.assinaturas where Estado = 3 and CodPacote = 6;" -N -s >> Base_Bemobi_RJ.txt
echo ""
echo ""
#Concatenar as bases em um único arquivo
cat Base_Bemobi_SP.txt >> blacklist.txt
cat Base_Bemobi_RJ.txt >> blacklist.txt
#Copiar arquivo para o servidores VSA1 e VRA1
echo "Copiando o arquivo para o servidores do SmartCampaign (VSA1 e VRA1)..."
sshpass -p CPnLPijJpFqY8vJxwKzf scp blacklist.txt nvtlocalv@10.8.129.172:/cygdrive/d/GMK/Servidores/SmartCampaign/assets/
sshpass -p CPnLPijJpFqY8vJxwKzf scp blacklist.txt nvtlocalv@10.43.1.172:/cygdrive/d/GMK/Servidores/SmartCampaign/assets/
#Remover arquivos temporários
rm -rf Base_Bemobi_SP.txt
rm -rf Base_Bemobi_RJ.txt
rm -rf blacklist.txt
echo ""
echo ""
#Chama bat para reiniciar serviço SmartCampaign
echo "Reiniciando o serviço SmartCampaign nos Servidores VSA1 e VRA1..."
echo ""
cmd.exe /C restart_smartcampaing.bat
sleep 5
