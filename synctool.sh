#!/bin/bash

do_transfer()
{
    echo "Введите путь к сайту"
    read SYNCFROMPATH

    echo "Введите IP сервера назначения"
    read SYNCWHERE
    echo "Введите порт сервера назначения (По умолчанию: 22)"
    read SYNCWHEREPORT
    SYNCWHEREPORT="${SYNCWHEREPORT:-22}"
    echo "Введите пользователя сервера назначения (По умолчанию: root)"
    read SYNCWHEREUSER
    SYNCWHEREUSER=${SYNCWHEREUSER:-root}
    echo "Введите путь к сайту на сервере назначения"
    read SYNCWHEREPATH

    rsync -avzP --size-only -e "ssh -p $SYNCWHEREPORT" $SYNCFROMPATH $SYNCWHEREUSER@$SYNCWHERE:$SYNCWHEREPATH
}

do_bitrix_transfer()
{
    BX_SYNCFROMPATH="/home/bitrix/"
    BX_BX_SYNCFROMPATH_SITE="www/"

    echo "Введите IP сервера назначения"
    read SYNCWHERE
    echo "Введите порт сервера назначения (По умолчанию: 22)"
    read SYNCWHEREPORT
    SYNCWHEREPORT="${SYNCWHEREPORT:-22}"
    echo "Введите пользователя сервера назначения (По умолчанию: root)"
    read SYNCWHEREUSER
    SYNCWHEREUSER=${SYNCWHEREUSER:-root}

    rsync -avzP --size-only -e "ssh -p $SYNCWHEREPORT" $BX_SYNCFROMPATH$BX_BX_SYNCFROMPATH_SITE $SYNCWHEREUSER@$SYNCWHERE:$BX_SYNCFROMPATH$BX_BX_SYNCFROMPATH_SITE
}

case "$1" in
    bitrix) 
        do_bitrix_transfer
        ;;
    isp)
        do_isp_transfer
        ;;
    *) 
        do_transfer
        ;;
esac