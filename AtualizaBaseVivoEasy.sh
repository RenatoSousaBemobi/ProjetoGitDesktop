#!/bin/bash

#Realizar o tratamento do arquivo disponibilizado pela operadora
echo ""
echo ""
read -p "Digite o nome do arquivo disponibilizado pela Vivo no S3: "
if [ -f "$REPLY" ]
then
        cat "$REPLY" >> Base_VivoEasy.txt
        sed -i '1d' Base_VivoEasy.txt
	#Apagar os dados do Banco
	mysql -h127.0.0.1 -P3306 -udbadm -pFEqrRsgGW8kbmBUINR2a -e"TRUNCATE TABLE vivoeasy.base_vivo_vivo_easy;" -N -s
	mysql -h127.0.0.1 -P3306 -udbadm -pFEqrRsgGW8kbmBUINR2a -e"TRUNCATE TABLE vivoeasy.base_bemobi_vivo_easy;" -N -s
	echo ""
	echo ""
	#Obter Base de MSISDNs na Bemobi (DDDs 1x 4x 5x)
	echo "Obtendo a Base de MSISDNs na Bemobi (DDDs 1x 4x 5x 6x)..."
	mysql -h10.43.1.100 -P3306 -udbadm -pFEqrRsgGW8kbmBUINR2a -e"SELECT CONCAT(DDDA,NUMA) as MSISDN FROM assinaturarecadovivo.assinaturas where Estado = 3 and CodPacote = 6;" -N -s >> Base_Bemobi_SP.txt
	echo ""
	echo ""
	#Obter Base de MSISDNs na Bemobi (DDDs 2x 3x 6x 7x 8x 9x)
	echo "Obtendo a Base de MSISDNs na Bemobi (DDDs 2x 3x 6x 7x 8x 9x)..."
	mysql -h10.8.129.102 -P3306 -udbadm -pFEqrRsgGW8kbmBUINR2a -e"SELECT CONCAT(DDDA,NUMA) as MSISDN FROM assinaturarecadovivo.assinaturas where Estado = 3 and CodPacote = 6;" -N -s >> Base_Bemobi_RJ.txt
	echo ""
	echo ""
	#Mesclar as bases em um único arquivo
	cat Base_Bemobi_SP.txt >> Base_BemobiVivoEasy.txt
	cat Base_Bemobi_RJ.txt >> Base_BemobiVivoEasy.txt
	#Subir Base da Vivo no Banco de Dados
	echo "Subindo a Base da Vivo no Banco de Dados..."
	echo ""
	echo ""
	mysql -h127.0.0.1 -P3306 -udbadm -pFEqrRsgGW8kbmBUINR2a -e"LOAD DATA LOCAL INFILE 'D:/Cygwin/home/nvtlocalv/Base_VivoEasy.txt' INTO TABLE vivoeasy.base_vivo_vivo_easy FIELDS TERMINATED BY '\n';" -N -s
	#Subir Base da Bemobi no Banco de Dados
	echo "Subindo a Base da Bemobi no Banco de Dados..."
	echo ""
	echo ""
	mysql -h127.0.0.1 -P3306 -udbadm -pFEqrRsgGW8kbmBUINR2a -e"LOAD DATA LOCAL INFILE 'D:/Cygwin/home/nvtlocalv/Base_BemobiVivoEasy.txt' INTO TABLE vivoeasy.base_bemobi_vivo_easy FIELDS TERMINATED BY '\n';" -N -s
	#Obter Base a ser Cancelada
	echo "Obtendo a Base a ser Cancelada..."
	echo ""
	echo ""
	mysql -h127.0.0.1 -P3306 -udbadm -pFEqrRsgGW8kbmBUINR2a -e"SELECT ntcl FROM vivoeasy.base_bemobi_vivo_easy WHERE ntcl NOT IN (SELECT ntcl FROM vivoeasy.base_vivo_vivo_easy);" -N -s >> A_Cancelar.txt
	#Obter Base a ser Assinada
	echo "Obtendo a Base a ser Assinada..."
	echo ""
	echo ""
	mysql -h127.0.0.1 -P3306 -udbadm -pFEqrRsgGW8kbmBUINR2a -e"SELECT ntcl FROM vivoeasy.base_vivo_vivo_easy WHERE ntcl NOT IN (SELECT ntcl FROM vivoeasy.base_bemobi_vivo_easy);" -N -s >> A_Assinar.txt
	#Obter Base Comum (MSISDNs que estão na Base da Vivo e também na Base da Bemobi)
	echo "Obtendo a Base Comum..."
	echo "São MSISDNs que estão na Base da Vivo e também na Base da Bemobi."
	echo "Serve apenas para anexar ao ticket, para conhecimento."
	echo ""
	echo ""
	mysql -h127.0.0.1 -P3306 -udbadm -pFEqrRsgGW8kbmBUINR2a -e"SELECT base_bemobi_vivo_easy.ntcl FROM vivoeasy.base_bemobi_vivo_easy INNER JOIN vivoeasy.base_vivo_vivo_easy ON base_bemobi_vivo_easy.ntcl=base_vivo_vivo_easy.ntcl;" -N -s >> Base_Comum.txt
	#Copiar arquivos para o servidor VRAP
	echo "Copiando arquivos para o servidor VRAP..."
	sshpass -p CPnLPijJpFqY8vJxwKzf scp A_Assinar.txt nvtlocalv@10.43.1.150:/cygdrive/d/GMK/Aplicativos/VIVO_ProcessamentoEmLote/VivoEasy/
	sshpass -p CPnLPijJpFqY8vJxwKzf scp A_Cancelar.txt nvtlocalv@10.43.1.150:/cygdrive/d/GMK/Aplicativos/VIVO_ProcessamentoEmLote/VivoEasy/
	sshpass -p CPnLPijJpFqY8vJxwKzf scp Base_Comum.txt nvtlocalv@10.43.1.150:/cygdrive/d/GMK/Aplicativos/VIVO_ProcessamentoEmLote/VivoEasy/
	#Excluir arquivos temporários
	rm -rf Base_Bemobi_SP.txt
	rm -rf Base_Bemobi_RJ.txt
	rm -rf "$REPLY"
	rm -rf Base_BemobiVivoEasy.txt
	rm -rf Base_VivoEasy.txt
	rm -rf A_Assinar.txt
	rm -rf A_Cancelar.txt
	rm -rf Base_Comum.txt
	echo ""
	echo ""
	sleep 4
	echo "Script finalizado com sucesso!"
	echo ""
	echo ""
	echo "========================================================================"
	echo -e "	        \033[0;33mATENÇÃO! Acesse o Servidor VRAP.\033[0m"
	echo -e "Entre no diretório \033[0;32mD:\GMK\Aplicativos\VIVO_ProcessamentoEmLote\VivoEasy\033[0m,"
	echo -e "copie o conteúdo dos arquivos \033[0;32mA_Cancelar.txt\033[0m e \033[0;32mA_Assinar.txt\033[0m para"
	echo -e "a aplicação \033[0;32mVIVO - Execução em Lote\033[0m, selecionando o tipo de execução"
	echo "correspondente a cada arquivo."
	echo "========================================================================"

	sleep 3

else
	echo ""
	echo "==========================================================================="
        echo -e "Arquivo não encontrado! '\033[0;33m"$REPLY"\033[0m' não é um arquivo ou não existe!"
	echo "Verifique se você digitou o nome correto (com extensão) e tente novamente!"
	echo "==========================================================================="
fi
