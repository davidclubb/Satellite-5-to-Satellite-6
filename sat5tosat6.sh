#!/bin/bash
#
#This script is for Migrating RHEL 6.5 and 6.7 Servers to Satellite 6
#
#Author: Brandon Smitley
#
#Last Modified April 13, 2017
#By Brandon Smitley

#Use a case statement to find what release you are on
case `cut -f2 -d\( /etc/redhat-release | cut -f1 -d\  | cut -f1 -d\)` in
Taroon)
        exit 1
        ;;
Nahant)
        exit 1
        ;;
Tikanga)

        exit 1
        ;;
Santiago)
#RHEL 6
#Variables
check=`cat /etc/redhat-release  | cut -d " " -f7`

#install the following or newer packages for RHEL 6
#Obtained from Red Hat
#python-rhsm-1.16.6-1.el6.x86_64.rpm
#python-urlgrabber-3.9.1-11.el6.noarch.rpm
#subscription-manager-1.16.8-8.el6.x86_64.rpm
#subscription-manager-migration-1.16.8-8.el6.x86_64.rpm
#subscription-manager-migration-data-2.0.27-1.el6.noarch.rpm
#yum-3.2.29-75.el6_8.noarch.rpm


#These files can be installed from and nfs or from Satellite 5 before the yum-rhn-plugin is removed
#I used an NFS incase I was disconnted from sat 5
#NFS
yum localinstall -y /nfs/sat5tosat6/rpms_for_sat6_migration/1.16/*.rpm


#From Satellite 5
#yum install python-rhsm-1.16.6-1.el6.x86_64.rpm python-urlgrabber-3.9.1-11.el6.noarch.rpm subscription-manager-1.16.8-8.el6.x86_64.rpm subscription-manager-migration-1.16.8-8.el6.x86_64.rpm subscription-manager-migration-data-2.0.27-1.el6.noarch.rpm yum-3.2.29-75.el6_8.noarch.rpm
#Install pem file if missing, I did this with NFS but  I am sure you could use scp or rsync
#You can obtain these pem files from you Red Hat representative or from another server
#Install the PEM for 6.5 if not persent
if [ $check == 6.5 ]; then
	if ! [ -s /etc/pki/product/69.pem ]; then
		#From NFS	
		cp -p /nfs/sat5tosat6/65pem/69.pem /etc/pki/product/
		echo "placing pem 6.5"
	fi
fi

#Install the PEM for 6.7 if not persent
if [ $check == 6.7 ]; then
        if ! [ -s /etc/pki/product/69.pem ]; then
                #From NFS
		cp -p /nfs/sat5tosat6/67pem/69.pem /etc/pki/product/
		echo "placing pem 6.7"
        fi
fi


if rpm -q yum-rhn-plugin > /dev/null; then
        yum remove -y yum-rhn-plugin
fi

if [ -f /etc/sysconfig/rhn/systemid ]; then
        rm -rf /etc/sysconfig/rhn/systemid
fi

#Get the certificate for your satellite 6 server
if ! [ -s /root/katello-ca-consumer-latest.noarch.rpm ] ; then
        wget -O /root/katello-ca-consumer-latest.noarch.rpm http://satellite6.com/pub/katello-ca-consumer-latest.noarch.rpm
fi

if ! rpm -q katello-ca-consumer-satellite.example.com > /dev/null; then
        yum install -y  /root/katello-ca-consumer-latest.noarch.rpm
fi

#Place activation key here
#I placed all 6.5 and 6.7 machines into or 6.7 Channel for Satellite 6
subscription-manager register --org="" --activationkey=""
yum clean all
yum install -y katello-agent

if rpm -q katello-agent > /dev/null; then
        clear
        echo "Registration successful!"
else
        clear
        echo "Registration NOT successful!"
fi

        ;;
Maipo)

        exit 1
        ;;
*)
        exit 1
        ;;
esac
