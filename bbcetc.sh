#!/bin/sh

# bbcetc.sh
# This script downloads and slightly converts some news podcasts. 

NEWS_DIR=/var/www/news_podcasts
WGET=/usr/bin/wget
YOU_DL=/usr/local/bin/youtube-dl
FFMPEG=/usr/bin/ffmpeg
LAME=/usr/bin/lame
TMP_DIR=/tmp
UA="Mozilla/5.0 (X11; Linux i686; rv:52.0) Gecko/20100101 Firefox/52.0"

#bbc
AUDIO_FILE=bbc.mp3
WGOT_FILENAME=$AUDIO_FILE.page
if [ -f $TMP_DIR/$AUDIO_FILE.page ] ; then
  rm -f $TMP_DIR/$AUDIO_FILE.page
fi
# download, 1st step 
$WGET \
  -U "$UA" \
  -O $TMP_DIR/$AUDIO_FILE.page \
  https://www.bbc.co.uk/programmes/p002vsn1
# parse and download, 2nd step 
if [ -s $TMP_DIR/$AUDIO_FILE.page ] ; then
  DL_URL=`cat $TMP_DIR/$AUDIO_FILE.page \
    | tr -d \\\n | sed -r 's/.+Available\ now//' | sed -r 's/GMT.+//' \
    | grep -oE 'bbc.co.uk/sounds/play/[0-9a-z]+'`
	if [ ! -z $DL_URL ] ; then
		if [ -f $TMP_DIR/$AUDIO_FILE.mp4file ] ; then
      rm -f $TMP_DIR/$AUDIO_FILE.mp4file
    fi
		MEDIA_FMT=`$YOU_DL \
      --user-agent "$UA" \
      -F http://$DL_URL \
      | egrep "[^0-9A-Za-z]mp4[^0-9A-Za-z]" | tail -n1 | sed -r "s/\ .+//g"`
		$YOU_DL \
      --user-agent "$UA" \
      -f $MEDIA_FMT \
      -o $TMP_DIR/$AUDIO_FILE.mp4file \
      http://$DL_URL
		if [ -s $TMP_DIR/$AUDIO_FILE.mp4file ] ; then
			$FFMPEG \
        -i $TMP_DIR/$AUDIO_FILE.mp4file \
        -acodec mp3 -b:a 64k -af volume=3 \
        $TMP_DIR/$AUDIO_FILE
			if [ -s $TMP_DIR/$AUDIO_FILE ] ; then
				mv -f $TMP_DIR/$AUDIO_FILE $NEWS_DIR
			fi
			rm -f $TMP_DIR/$AUDIO_FILE.mp4file
		fi
	fi
	rm -f $TMP_DIR/$AUDIO_FILE.page
fi

#cbc
WGOT_FILENAME=cbc.mp3
if [ -f $TMP_DIR/$WGOT_FILENAME ] ; then
	rm -f $TMP_DIR/$WGOT_FILENAME
fi
$WGET \
  -U "$UA" \
  -O $TMP_DIR/$WGOT_FILENAME \
  http://podcast.cbc.ca/mp3/hourlynews.mp3
if [ -s $TMP_DIR/$WGOT_FILENAME ] ; then
	mv -f $TMP_DIR/$WGOT_FILENAME $NEWS_DIR
fi

#npr
WGOT_FILENAME=npr.mp3
if [ -f $TMP_DIR/$WGOT_FILENAME.128k.mp3 ] ; then
	rm -f $TMP_DIR/$WGOT_FILENAME.128k.mp3
fi
$WGET \
  -U "$UA" \
  -O $TMP_DIR/$WGOT_FILENAME.128k.mp3 \
  http://public.npr.org/anon.npr-mp3/npr/news/newscast.mp3
if [ -s $TMP_DIR/$WGOT_FILENAME.128k.mp3 ] ; then
	$LAME \
    -b 64k \
    $TMP_DIR/$WGOT_FILENAME.128k.mp3 \
    $TMP_DIR/$WGOT_FILENAME
	if [ -s $TMP_DIR/$WGOT_FILENAME ] ; then
		mv -f $TMP_DIR/$WGOT_FILENAME $NEWS_DIR
	fi
	rm -f $TMP_DIR/$WGOT_FILENAME.128k.mp3
fi

