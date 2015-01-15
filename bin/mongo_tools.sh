#!/bin/bash
# -*- coding: utf-8; -*-
#
# mongo_tools.sh :  MongoDB Tools {Backup / Restore / Delete}
# 
# Copyright (C) 2015 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#

PGNAME=$(basename $0)
OPTIONS=""

usage() {
	echo "Usage: $PGNAME [OPTIONS]"
	echo ""
	echo "Options:"
	echo "  --help                  show this message."
	echo "  -h, --host arg          mongodb host. [default : localhost]"
	echo "  -p, --port arg          mongodb port. [default : 27017]"
	echo "  -n, --dbname arg        mongodb name. (REQUIRED)"
	echo "  -u, --user arg          username."
	echo "  -w, --pass arg          password."
	echo "  {-B arg |-R arg | -D}   backup or restore or delete (REQUIRED)"
	echo "                          -B : directory to backup to"
	echo "                          -R : directory to restore from"
	echo ""
	exit 1
}

HOST=localhost
PORT=27017

if [ $# -eq 0 ]; then
	usage
fi

for OPT in "$@"
do
	case "$OPT" in
		'--help' )
			usage
			exit 1
			;;
		'-h'|'--host' )
			if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
				usage
			fi
			HOST=$2
			shift 2
			;;
		'-p'|'--port' )
			if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
				usage
			fi
			PORT=$2
			shift 2
			;;
		'-n'|'--dbname' )
			if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
				usage
			fi
			DBNAME=$2
			shift 2
			;;
		'-u'|'--user' )
			if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
				usage
			fi
			OPTIONS="$OPTIONS -u $2"
			USER=$2
			shift 2
			;;
		'-w'|'--pass' )
			if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
				usage
			fi
			OPTIONS="$OPTIONS -p $2"
			shift 2
			;;
		'-B' )
			if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
				echo "aaa"
				usage
			elif [[ $TYPE ==  restore ]] || [[ $TYPE == delete ]]; then
				usage
			fi
			TYPE=backup
			BACKUP=$2
			shift 2
			;;
		'-R' )
			if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
				usage
			elif [[ $TYPE ==  backup ]] || [[ $TYPE == delete ]]; then
				usage
			fi
			TYPE=restore
			RESTORE=$2
			shift 2
			;;
		'-D' )
			if [[ $TYPE ==  backup ]] || [[ $TYPE == restore ]]; then
				usage
			fi
			TYPE=delete
			shift 1
			;;
		-*)
			usage
			;;
	esac
done

if [[ -z $DBNAME ]]; then
	usage
fi

export TIME=`date "+%Y%m%d%H%M%S"`

if [[ $TYPE == backup ]]; then
	mkdir -p $BACKUP 
	if [[ $? != 0 ]]; then
		exit
	fi
	cd $BACKUP
fi

case $TYPE in
	"backup" )
		echo "backup start"
		mongodump -h ${HOST}:${PORT} -d ${DBNAME} ${OPTIONS} -o ${TIME}
		exit
		;;
	"restore" )
		echo "restore start"
		mongorestore -h ${HOST}:${PORT} -d ${DBNAME} ${OPTIONS} --drop ${RESTORE}
		exit
		;;
	"delete" )
		echo "delete start"
		mongo ${HOST}:${PORT}/${DBNAME} ${OPTIONS} <<EOF
show dbs
use ${DBNAME}
db.dropDatabase()
show dbs
EOF
		;;
	* )
		usage
		;;
esac


