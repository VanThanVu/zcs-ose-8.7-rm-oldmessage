#!/bin/bash
THEDATE=$(date -d "-180 day" +"%m/%d/%y")
THEFOLDER=inbox
ZIMBRA_BIN=/opt/zimbra/bin

touch /tmp/deleteOldMessagesList.txt
cat /root/list.txt | while read THEACCOUNT
do
for i in `$ZIMBRA_BIN/zmmailbox -z -m $THEACCOUNT search -l 1000 "in:/$THEFOLDER ( before:$THEDATE )" | grep conv | sed -e "s/^\s\s*//" | sed -e "s/\s\s*/ /g" | cut -d" " -f2`
do
if [[ $i =~ [-]{1} ]]
then
MESSAGEID=${i#-}
echo "deleteMessage $MESSAGEID" >> /tmp/deleteOldMessagesList.txt
echo "deleteMessage $THEACCOUNT $MESSAGEID"
echo -n "#" >> /tmp/deletemails.log
else
echo "deleteConversation $i" >> /tmp/deleteOldMessagesList.txt
echo "deleteConversation $THEACCOUNT $i"
echo -n "*" >> /tmp/deletemails.log
fi
done
$ZIMBRA_BIN/zmmailbox -z -m $THEACCOUNT < /tmp/deleteOldMessagesList.txt >> /tmp/process.log
rm -f /tmp/deleteOldMessagesList.txt
echo "$THEACCOUNT completed " >> /tmp/deletemails.log
done
