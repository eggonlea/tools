#!/bin/bash

TMP=/tmp/webwatch.$$
mkdir -p ${TMP}

ORIG=${TMP}/orig
CURR=${TMP}/curr
DIFF=${TMP}/diff

if [ $# -ne 1 ]
then
    echo "Usage: $0 <URL>"
    exit 1
fi

date
echo "Fetching initial content"
curl $1 > ${ORIG} 2> /dev/null

if [ $? -ne 0 ]
then
    date
    echo "Failed to fetch URL [$1]"
    exit 2;
fi

while true
do
    sleep 30m
    curl $1 > ${CURR} 2> /dev/null
    if [ $? -ne 0 ]
    then
        date
        echo "Failed to fetch URL [$1]"
        exit 3;
    fi

    diff ${ORIG} ${CURR} > ${DIFF}
    if [ $? -ne 0 ]
    then
        echo ""
        date
        echo "Change detected"
        echo "=====" >> ${DIFF}
        echo $1 >> ${DIFF}
        BODY=`cat ${DIFF}`
        /home/li/bin/sendgmail.py -s "USCF ID" -m "${BODY}"
        break
    else
        echo -n "."
    fi
done

date
echo "Done"
