#!/bin/bash

# THIS IS A FRAGILE SYSTEM, HANDLE WITH CARE.
# --------------------------------------------------------------------------- #
  MAIN="$1"
# --------------------------------------------------------------------------- #
  SHDIR=`dirname \`realpath $0\`` #;cd $SHDIR
  if [ ! -f "$MAIN" ]; then exit 0; fi
  MAINPATH=`realpath "$MAIN" | rev | cut -d "/" -f 2- | rev`
  MAINNAME=`basename "$MAIN" | rev | cut -d "." -f 2- | rev`
  MAIN="${MAINPATH}/${MAINNAME}.mdsh"
  if [ ! -f "$MAIN" ]; then exit 0; fi
  OUTPUTFORMAT=`echo $* | sed 's/ /\n/g' | #
                egrep '^html$|^pdf$' | head -n 1`
  if [ `echo $OUTPUTFORMAT | wc -c` -lt 3 ];then exit 0;fi
  OUTPUT="${MAINPATH}/${MAINNAME}.${OUTPUTFORMAT}"

# =========================================================================== #
# CONFIGURE                                                                   #
# =========================================================================== #
  FUNCTIONSBASIC="$SHDIR/basic.functions"
  TMPDIR="/tmp";SELECTLINES="tee"
# --------------------------------------------------------------------------- #
  TMPID=$TMPDIR/TMP`date +%Y%m%H``echo $RANDOM | cut -c 1-4`
  SRCDUMP=${TMPID}.maindump
  FUNCTIONS="$TMPID.functions"; cat $FUNCTIONSBASIC > $FUNCTIONS
# --------------------------------------------------------------------------- #
# INCLUDE                                                                     #
# --------------------------------------------------------------------------- #
  source "$SHDIR/prepress.functions"
  source "$SHDIR/page.functions"
  source "$SHDIR/text.functions"

  source "$SHDIR/output.functions"
  source "$SHDIR/href.functions"
  source "$FUNCTIONS"

# =========================================================================== #
# ACTION STARTS NOW!
# =========================================================================== #
# DO CONVERSION
# --------------------------------------------------------------------------- #
  mdsh2src "$MAIN"
# --------------------------------------------------------------------------- #
# CREATE TARGET OUTPUT
# --------------------------------------------------------------------------- #
  if [ `ls $SRCDUMP 2>/dev/null | wc -l` -gt 0 ]; then

   for D in $preOutput; do $D ;done
            $lastAction
   for D in $postOutput; do $D ;done

  # ----------------------------------------------------------------------- #
  else echo '$SRCDUMP not existing'; 
  # ----------------------------------------------------------------------- #
  fi

# =========================================================================== #
# CLEAN UP (MAKE SURE $TMPID IS SET FOR WILDCARD DELETE)

  if [ `echo ${TMPID} | wc -c` -ge 4 ] && 
     [ `ls ${TMPID}*.* 2>/dev/null | wc -l` -gt 0 ]
  then  rm ${TMPID}*.* ;fi
  if [ -f "$TMPDIR/FOGRA39L.icc" ];then rm $TMPDIR/FOGRA39L.icc; fi
  if [ -f "$TMPDIR/pdfx-1a.xmp*" ];then rm $TMPDIR/pdfx-1a.xmp*; fi


exit 0;

