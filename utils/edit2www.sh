#!/bin/bash

# CREATE WWW VERSION FROM SVG WORK FILE                                       #

# --------------------------------------------------------------------------- #
# TODO: Xprovide subfolder option (like lokalize.sh)
#       X-f => force new write
#       Xcreate "_" if it does not exist
#       Xignore XX_ layers
#       Xmulti layer support
#       Xcheck not by date but md5 of source file
#       Xrm different format
# --------------------------------------------------------------------------- #

# =========================================================================== #
# SET VARIABLES 
# --------------------------------------------------------------------------- #
  SHPATH=`dirname \`readlink -f $0\``
  SVGROOT="../_"
  THISSCRIPT="http://freeze.sh/utils/edit2www.sh"
# =========================================================================== #
# CHECK INPUT
# --------------------------------------------------------------------------- #
   ARGUMENTS=`echo $* | sed 's/ -[a-z]\b//g'`
   if [ `echo $ARGUMENTS | wc -c` -gt 1  ]
    then if [ -f `echo $ARGUMENTS | sed 's/\.svg$//'`.svg ]
         then SVGALL=`echo $ARGUMENTS | sed 's/\.svg$//'`.svg
         elif [ -d $ARGUMENTS ]
         then SVGALL=`find $ARGUMENTS -name "*.svg" | #
                      grep "EDIT/" | grep "\.svg$"`   #
         else echo "SOMETHING SEEMS WRONG";exit 0;fi
    else SVGALL=`find $SVGROOT -name "*.svg" | #
                 grep "EDIT/" | grep "\.svg$"`
         N=`echo $SVGALL | sed 's/ /\n/g' | wc -l`
        echo -e "$N FILES TO PROCESS. \
                 THIS WILL TAKE SOME TIME.\n" | tr -s ' '
        read -p "SHOULD WE DO IT? [y/n] " ANSWER
        if [ X$ANSWER != Xy ] ; then echo "BYE."; exit 1;
                                else echo; fi
   fi
   if [ `echo $* | sed 's/ /\n/g' | #
         grep -- "-f" | wc -l` -gt 0 ];then FORCEWRITE="YES"; fi
# =========================================================================== #
# CHECK EXIFTOOL
# --------------------------------------------------------------------------- #
  if [ `hash exiftool 2>&1 | wc -l` -gt 0 ]
  then EXIF="OFF";else EXIF="ON"; fi

# =========================================================================== #
# FUNCTIONS (USED LATER)
# =========================================================================== #
  function saveOptimized() {

    EDITSRC=$1;SAVETHIS=$2;ORIGINAL=$EDITSRC
    MD5SRC=`md5sum "$EDITSRC" | cut -d " " -f 1`;
 
    cp ${EDITSRC} ${EDITSRC}.original # BACKUP ORIGINAL
  # ----------------------------------------------------------------------- #
  # REMOVE 'XX_' LAYERS
  # ----------------------------------------------------------------------- #
    B=N`md5sum ${EDITSRC} | cut -c 1-3`L
    S=S`md5sum ${EDITSRC} | cut -c 1-3`P
    L=L`md5sum ${EDITSRC} | cut -c 1-3`O
  # ----  
    sed ":a;N;\$!ba;s/\n/$B/g" ${EDITSRC} | # RM ALL LINEBREAKS (BUT SAVE)
    sed "s/ /$S/g"                        | # RM ALL SPACE (BUT SAVE)
    sed 's/<g/\n<g/g'                     | # REDO GROUP OPEN + NEWLINE
    sed "/mode=\"layer\"/s/<g/$L/g"       | # PLACEHOLDER FOR LAYERGROUP OPEN
    sed ':a;N;$!ba;s/\n//g'               | # RM ALL LINEBREAKS (AGAIN)
    sed "s/$L/\n<g/g"                     | # REDO LAYERGROUP OPEN + NEWLINE
    sed '/^[ ]*$/d'                       | # RM EMPTY LINES
    sed 's/<\/svg>/\n&/g'                 | # PUT SVG CLOSE ON NEW LINE
    sed 's/display:none/display:inline/g' | # MAKE VISIBLE EVEN WHEN HIDDEN
    grep -v 'label="XX_'                  | # REMOVE XXCLUDED LAYERS
    grep -v "^</svg>"                     | # REMOVE CLOSING TAG
    tee > ${EDITSRC}.layers                 # WRITE TO TEMPORARY FILE
  # ----  
    head -n 1   ${EDITSRC}.layers > ${EDITSRC}.head # GET HEAD
    sed -i '1d' ${EDITSRC}.layers                   # GET LAYERS (RM LINE 1)
  # ----   
    LAYERS=`cat ${EDITSRC}.layers            | # USELESS USE OF CAT
            sed  '/^<g/s/pe:label/\nlabel/'  | # PUT NAME LABEL ON NL
            grep '^label' | cut -d "\"" -f 2 | # EXTRACT NAME 
            sort -u`                           # SORT/UNIQ
  # ----   
    if [ `grep "SPLIT LAYERS" ${EDITSRC}.original | wc -l` -gt 0 ]
    then LAYERSELECT="$LAYERS"
         SAVEPATH=`echo $SAVETHIS | rev  | #
                   cut -d "/" -f 2- | rev` #
    else LAYERSELECT=".";SPLITLAYERS="false"
    fi

   # ---------------------------------------------------------------- #
    for LAYERGREP in $LAYERSELECT 
     do
      # ----------------------------------------------------------- #
        if [ "$SPLITLAYERS" != "false" ];then  
              SAVENAME=`echo $LAYERGREP | #
                        sed 's/[^-\_a-zA-Z0-9]*//g'`
              SAVETHIS=$SAVEPATH/$SAVENAME
        fi

        checkOutput ${EDITSRC} ${SAVETHIS}

        if [ "$DOSAVE" == 1 ];then

        cat ${EDITSRC}.head                            >  ${EDITSRC}
        if [ "$SPLITLAYERS" != "false" ];then  
        egrep "label=\"$LAYERGREP\"" ${EDITSRC}.layers >> ${EDITSRC}
        else
        cat ${EDITSRC}.layers                          >> ${EDITSRC}
        fi
        echo  "</svg>"                                 >> ${EDITSRC}
        sed -i "s/$S/ /g" ${EDITSRC} ; sed -i "s/$B/\n/g" ${EDITSRC}
      # ----------------------------------------------------------- #
     
       # HOW TO SAVE OPTIMIZED
       # ---------------------
       # echo -e "\e[34mCHECK $EDITSRC\e[0m"
         HASIMG=`grep "<image" $EDITSRC | wc -l`
         if [ $HASIMG -gt 0 ]; then
     
         # PIXEL: BASE EXPORT (PNG)                                 #
         # -------------------------------------------------------- #
           inkscape --export-png=${SAVETHIS}.png \
                    --export-background-opacity=0   \
                    $EDITSRC > /dev/null 2>&1
           NUMCOLOR=`convert ${SAVETHIS}.png -format %c \
                     -depth 8  histogram:info:- | #
                     sed '/^[[:space:]]*$/d' | wc -l`
           NOTRANSPARENCY=`convert ${SAVETHIS}.png \
                           -format "%[opaque]" info:`
     
           if [ X$NOTRANSPARENCY = "Xtrue" ]; then
     
           # NOT TRANSPARENT: COMPRESS (JPG/GIF)                    #
           # ------------------------------------------------------ #
             if [ $NUMCOLOR -lt 256 ]; then
                  echo -e "\e[42m SAVE ${SAVETHIS}.gif \e[0m";
                  convert ${SAVETHIS}.png \
                          ${SAVETHIS}.gif
                  SAVETHISFORMAT="gif"
             else
                  echo -e "\e[42m SAVE ${SAVETHIS}.jpg \e[0m";
                  convert ${SAVETHIS}.png \
                          -quality 90 \
                          ${SAVETHIS}.jpg
                  SAVETHISFORMAT="jpg"
             fi
           else   echo -e "\e[42m SAVE ${SAVETHIS}.png \e[0m"
                  SAVETHISFORMAT="png"
           fi;    SAVED=`ls ${SAVETHIS}.${SAVETHISFORMAT} | #
                         head -n 1`
                  if [ "$EXIF" == ON ]; then
                        exiftool -Software="$THISSCRIPT" \
                       -Source="$MD5SRC" $SAVED > /dev/null 2>&1
                  fi
         else
     
         # VECTOR: BREAK FONTS, FORGET ABOUT HIDDEN STUFF         #
         # ------------------------------------------------------ #
           echo -e "\e[102m\e[97m SAVE ${SAVETHIS}.svg \e[0m";
           sed -i 's/opacity:[0-9\.]*/opacity:1/g' $EDITSRC
           inkscape --export-pdf=${SAVETHIS}.pdf \
                    -T $EDITSRC > /dev/null 2>&1
           inkscape --export-plain-svg=${SAVETHIS}.svg \
                    ${SAVETHIS}.pdf > /dev/null 2>&1
           SAVETHISFORMAT="svg"
           SRCSTAMP="<!-- $MD5SRC ("`date +%d.%m.%Y" "%T`")-->"

           sed -i "1s,^.*$,&\n$SRCSTAMP,"  ${SAVETHIS}.svg
        fi
          for SAVETHISOLD in `ls ${SAVETHIS}.* | #
                              grep -v ".${SAVETHISFORMAT}$"`
                   do if [ -f "$SAVETHISOLD" ];then
                           rm "$SAVETHISOLD"
                      fi
                  done
     fi
   # --------------------------------------------------------------------- #
     done
  # ----------------------------------------------------------------------- #
    rm ${EDITSRC}.layers ${EDITSRC}.head  # RM TMP FILES
    mv ${EDITSRC}.original ${EDITSRC}     # RESTORE ORIGINAL
  }
# =========================================================================== #
  function checkOutput() {

    SOURCE=$1;OUTPUT=$2;OUTPUTPATH=`echo $OUTPUT     | #
                                    rev              | #
                                    cut -d "/" -f 2- | #
                                    rev`               #

    if [ `ls ${OUTPUT}.* 2> /dev/null | wc -l` -lt 1 ]; then

          echo "NO WWW VERSION"
          DOSAVE=1
    else
          SAVED=`ls -t ${OUTPUT}.* | head -n 1`

          if [ "$SAVED" -nt "$SOURCE" ] &&
             [ "$FORCEWRITE" != "YES"  ]; then
               echo "$SAVED IS UP-TO-DATE ($EDITSRC)"
               DOSAVE=0
          else
            # ------------------------------------------------------- #
              if [ "$EXIF" == "ON" ] &&
                 [ `echo $SAVED | grep -v "\.svg$" | wc -l` -gt 0 ]
              then  MD5OUT=`exiftool $SAVED | #
                            grep "^Source[ ]*:[ ]*[a-f0-9]*" | #
                            cut -d ":" -f 2 | #
                            sed 's/[^a-f0-9]*//g'`
              fi
              if [ `echo $SAVED | grep "\.svg$" | wc -l` -gt 0 ]
              then    MD5OUT=`grep '<!-- [a-f0-9]' $SAVED | #
                              cut -d " " -f 2`
              fi
            # ------------------------------------------------------- #
              if [ "$MD5OUT" != "$MD5SRC" ];then
                    echo -e "\e[31m$SAVED NEEDS UPDATE\e[0m ($EDITSRC)"
                    DOSAVE=1
              else  echo "$SAVED IS UP-TO-DATE ($EDITSRC)"
                    DOSAVE=0
              fi
            # ------------------------------------------------------- #
          fi
    fi

  }
# =========================================================================== #

# =========================================================================== #
#  LOOP THROUGH ALL SVG FILES (AS DEFINED ABOVE)
# =========================================================================== #
  for EDITSRC in $SVGALL
   do
         EDITPATH=`echo "$EDITSRC"  | rev | #
                   cut -d "/" -f 2- | rev`  #
         WWWPATH=`echo "$EDITPATH"  |       #
                  sed 's,/EDIT.*$,/_,g'`    #

         BASENAME=`basename "$EDITSRC" |    #
                   cut -d "." -f 1`         #

         if [ ! -d "$WWWPATH" ];then mkdir -p "$WWWPATH";fi

         saveOptimized "$EDITSRC" "${WWWPATH}/${BASENAME}"

  done
# =========================================================================== #

exit 0;

