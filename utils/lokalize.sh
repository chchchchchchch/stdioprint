#!/bin/bash

# MAKE LOKAL ON DEMAND (KEEP THE BLOBS OUT)
# TODO: -f => force download
#       check for README/LICENSE AT REMOTE LOCATION
# ====================================================================== #
  SRCPTH=`echo $* | sed 's/ /\n/g' | head -n 1`
# ---------------------------------------------------------------------- #
  if [ -f "$SRCPTH" ]
  then ALLSRC="$SRCPTH"
  elif [ -d "$SRCPTH" ]
  then ALLSRC=`find $SRCPTH -name "*.remote"`
  else echo "NO INPUT PROVIDED"
       echo "----"; echo "CHECK/DOWNLOAD ALL SOURCES."
       SRCPTH="../_"
       ALLSRC=`find $SRCPTH -name "*.remote"`
  fi
# --
  if [ "$ALLSRC" == "" ];then echo "NOTHING TO DO.";exit 0;fi
# --
  N=`cat $ALLSRC | grep "^[ \t]*https\?:" | wc -l`
  echo -e "THIS MEANS CHECKING $N FILES \
           AND WILL TAKE SOME TIME.\n" | tr -s ' '
  read -p "SHOULD WE DO IT? [y/n] " ANSWER
  if [ "$ANSWER" != y ];then echo "BYE."; exit 1;
                        else echo; fi
# ---------------------------------------------------------------------- #
  echo -e "THE FOLLOWING PROCESS WILL DOWNLOAD FILES
  FROM DIFFERENT SOURCES WITH DIFFERENT COPYRIGHTS.
  IF NOT STATED OTHERWISE ALL RIGHTS RESERVED TO THE AUTHORS." | #
  sed 's/^[ ]*//'
  read -p "I KNOW WHAT I'M DOING? [y/n] " ANSWER
  if [ "$ANSWER" != y ];then echo "BYE"; exit 1; \
                        else echo; fi
# ====================================================================== #
  for SRC in $ALLSRC
    do
      SRCDIR=`echo $SRC | rev | cut -d "/" -f 2- | rev`
    # ------------------------------------------------- #
     (IFS=$'\n'
      for REMOTE in `cat $SRC               | # USELESS USE OF CAT
                     grep -v "^%"           | # NO LINES STARTING WITH %
                     grep "^[ \t]*https\?:" | # SELECT HTTP(S)
                     sed 's/^[ \t]*//'      | # RM LEADING BLANKS
                     sort -u`                 # SORT/UNIQ
       do 
          if [ `echo $REMOTE |        # ECHO $REMOTE
                grep " -*> " |        # SELECT IF '-(--)>'
                wc -l` -gt 0 ]        # COUNT AND CHECK
          then  LOKALNAME=`echo $REMOTE     |      # ECHO $REMOTE
                           sed 's/^.* -*> //'`     # CUT AFTER ->
                  REMOTE=`echo $REMOTE      |      # ECHO $REMOTE
                          sed 's/ -*> .*$//'`      # CUT BEFORE ->
          else  LOKALNAME=`curl -sIL "$REMOTE"   | # CHECK URL
                           grep "^Location"      | # EXTRACT LOCATION
                           rev                   | # REWIND 
                           cut -d "/" -f 1       | # EXTRACT LAST FIELD
                           rev                   | # REWIND
                           tr -d '\r'`             # RM CARRIAGE RETURN
              # -- FALLBACK ------------------------------------------- #
                if [ `echo $LOKALNAME | wc -c` -lt 2 ]
                then  LOKALNAME=`echo "$REMOTE"  | # ECHO $REMOTE
                                 cut -d " " -f 1 | rev | # SELECT/REVERT
                                 cut -d "/" -f 1 | rev`  # SELECT/REVERT
                fi
              # ------------------------------------------------------- #
                   REMOTE=`echo "$REMOTE"  |       # ECHO $REMOTE
                           cut -d " " -f 1`        # SELECT FIELD
          fi
               LOKALNAME=`echo $LOKALNAME  | # ECHO $LOKALNAME
                          sed 's/^[ ]*//'  | # RM LEADING BLANCS
                          sed 's/[ ]*$//'`   # RM TRAILING BLANCS
               if [ -d $SRCDIR/$LOKALNAME ]
               then REMOTENAME=`basename $REMOTE`
                    LOKALNAME=`echo $LOKALNAME/$REMOTENAME | #
                               tr -s '/'`
               fi
                  LOKAL="$SRCDIR/$LOKALNAME" # ADD SRC PATH
               LOKALDIR=`echo $LOKAL | rev |      # ECHO $LOKAL/REWIND
                         cut -d "/" -f 2-  | rev` # SELECT/REWIND
               if [ ! -d $LOKALDIR ]       # IF NECESSARY ...
               then mkdir -p $LOKALDIR     # ... CREATE DIRECTORY
               fi

     # IF REMOTE FILE EXISTS                          #
     # ---------------------------------------------- #
       if [ `curl -s -o /dev/null -IL  \
             -w "%{http_code}" "$REMOTE"` == '200' ]
       then 
            # IF LOKAL FILE EXISTS                           #
            # ---------------------------------------------- #
              if [ -f "$LOKAL" ]
              then 
                   LTIME=`date -r "$LOKAL" +%Y%m%d%H%M.%S` 
                   CHECKSUMLOKAL=`md5sum "$LOKAL" | cut -c 1-32`

                 # DOWNLOAD IF REMOTE IS NEWER                    #
                 # ---------------------------------------------- #
                   if [ `curl "$REMOTE" -z "$LOKAL" -o "$LOKAL" \
                         -s -L -w %{http_code}` == "200" ]
                   then  echo "CHECKING:   $LOKAL"
                         curl -sRL "$REMOTE" -o tmp.tmp

                         if [ -f tmp.tmp ];then
                              CHECKSUMREMOTE=`md5sum tmp.tmp | #
                                              cut -c 1-32`     #
                              if [ "$CHECKSUMLOKAL" != "$CHECKSUMREMOTE" ]
                              then cp -p tmp.tmp "$LOKAL"
                              else touch -t "$LTIME" $LOKAL
                                   echo "UP-TO-DATE: $LOKAL"
                              fi
                              rm tmp.tmp
                         fi
                   else  echo "UP-TO-DATE: $LOKAL"
                   fi;else

                 # DOWNLOAD IF NO LOKAL FILE                      #
                 # ---------------------------------------------- #
                         curl -RL "$REMOTE" -o "$LOKAL"
               fi
       fi
      done;)
    # ------------------------------------------------- #
   done
# ====================================================================== #

exit 0;
