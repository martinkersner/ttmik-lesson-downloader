#!/usr/bin/env bash
# Martin Kersner, m.kersner@gmail.com
# 2016/11/27

LEVEL=$1

# create directory for downloaded lectures
mkdir -p $LEVEL

TMP_FILE=$(mktemp /tmp/ttmik-download.XXXXX)
TMP_FILE2=$(mktemp /tmp/ttmik-download.XXXXX)
TMP_FILE3=$(mktemp /tmp/ttmik-download.XXXXX)
TMP_FILE4=$(mktemp /tmp/ttmik-download.XXXXX)

LEVEL_URL="http://www.talktomeinkorean.com/category/lessons/level-""$LEVEL""/"

# find out number of pages
wget -O $TMP_FILE $LEVEL_URL
NUM_PAGES=`cat $TMP_FILE | grep "page larger" | grep -o "/page/.*</a>" | grep -o "[0-9]*" | sort | tail -n 1`

for (( INDEX=1; INDEX<=$NUM_PAGES; INDEX++ )); do
  LEVEL_PAGE_URL="$LEVEL_URL""/page/"$INDEX"/"

  # get links from each level page
  wget -O $TMP_FILE $LEVEL_PAGE_URL

  cat $TMP_FILE | grep -o "http://www.talktomeinkorean.com/lessons/level-""$LEVEL"".*/\"" \
    | sort | uniq | tr -d "\"" >> $TMP_FILE2

  cat $TMP_FILE | grep -o "http://www.talktomeinkorean.com/lessons/level""$LEVEL"".*/\"" \
    | sort | uniq | tr -d "\"" >> $TMP_FILE2
done

# extract links to mp3 and pdf files
while read -r URL; do
  wget -O $TMP_FILE3 "$URL"
  # mp3
  cat $TMP_FILE3 | grep "http://hwcdn.libsyn.com/.*\" onclick" | sed "s/href=\"//" \
    | grep -o "http.*onclick" | sed "s/\"\ onclick//" | sort | uniq >> $TMP_FILE4
  cat $TMP_FILE3 | grep "http://traffic.libsyn.com/.*\" onclick" | sed "s/href=\"//" \
    | grep -o "http.*onclick" | sed "s/\"\ onclick//" | sort | uniq >> $TMP_FILE4

  # pdf
  cat $TMP_FILE3 | grep "http://ec.libsyn.com/.*\" onclick" | sed "s/href=\"//" \
   | grep -o "http.*onclick" | sed "s/\"\ onclick//" | sort | uniq >> $TMP_FILE4
  cat $TMP_FILE3 | grep "http://traffic.libsyn.com/.*\" onclick" | sed "s/href=\"//" \
   | grep -o "http.*onclick" | sed "s/\"\ onclick//" | sort | uniq >> $TMP_FILE4
done < "$TMP_FILE2"


# download mp3 and pdf
while read -r URL; do
  TMP_NAME=`echo "$URL" | sed "s/\?.*//" | grep -o "ttmik.*"`
  wget -O "$LEVEL""/""$TMP_NAME" "$URL"
done < "$TMP_FILE4"

rm -rf $TMP_FILE $TMP_FILE2 $TMP_FILE3 $TMP_FILE4
