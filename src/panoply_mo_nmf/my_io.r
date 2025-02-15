#
# Copyright (c) 2020 The Broad Institute, Inc. All rights reserved.
#
## ##############################################################################
## Author:   Karsten Krug
## Purpose:  - collection of functions for reading/writing various data formats

library(pacman)
##p_load_gh("cmap/cmapR")

## deal with non-unique rid
parse.gctx2 <- function( fname, ... ){
  
  p_load(cmapR)
  p_load(magrittr)
  
  
  gct <- try(parse.gctx(fname, ...))
  
  if(class(gct) == 'try-error' ){
    ## - cmapR functions stop if ids are not unique
    ## - import gct using readLines and make ids unique
    if(length(grep('rid must be unique', gct) ) > 0) {
      gct.tmp <- readLines(fname)
      #first column
      rid <- gct.tmp %>% sub('\t.*','', .)
      #gct version
      ver <- rid[1]
      #data and meta data columns
      meta <- strsplit(gct.tmp[2], '\t') %>% unlist() %>% as.numeric()
      if(ver=='#1.3')
        rid.idx <- (meta[4]+3) : length(rid)
      else
        rid.idx <- 4:length(rid)
      
      #check whether ids are unique
      if(length(rid[rid.idx]) > length(unique(rid[rid.idx]))){
        warning('rids not unique! Making ids unique and exporting new GCT file...\n\n')
        #make unique
        rid[rid.idx] <- make.unique(rid[rid.idx], sep='_')
        #other columns
        rest <- gct.tmp %>% sub('.*?\t','', .)
        rest[1] <- ''
        gct.tmp2 <- paste(rid, rest, sep='\t') 
        gct.tmp2[1] <-  sub('\t.*','',gct.tmp2[1])
        
        #export
        gct.unique <- sub('\\.gct', '_unique.gct', fname) %>% sub('.*/', '', .)
        writeLines(gct.tmp2, con=gct.unique)
        
        #import using cmapR functions
        gct <- parse.gctx(fname = gct.unique)
      }
    } #end if 'rid not unique'
  }
  
  return(gct)
}

## ############################################################
## convert ssv to gct 1.3
##
## ed.str: experimental design file, csv
## example:
## Sample.ID,Sample,Experiment,Channel,Type,QC.status
##C3N.00858,C3N-00858,1,127N,Tumor,QC.pass
##C3N.00858.N,C3N-00858,1,127C,Normal,QC.fail
##C3L.01252.N,C3L-01252,1,128N,Normal,QC.fail
##
ssv2gct <- function(ssv.str, ed.str,
                    exprs.regex=paste('\\|log2_TMT_(', paste(126:131, collapse='|'),')(C|N|)_.*_median$',sep='')
){
  
  # import files  
  ssv <- read.ssv2(file = ssv.str)
  ed <- read.csv(ed.str, stringsAsFactors = F)  
  
  # extract expression data
  mat <- ssv[, grep( exprs.regex, colnames(ssv))] %>% data.matrix
  
  ## CAUTION: rows in 'ed' and columns in 'mat' are supposed to be in the SAME ORDER
  sm.id <- colnames(mat)
  cdesc <- data.frame(SM.id=sm.id, ed, stringsAsFactors = F)
  cid <- ed$Sample.ID
  rownames(cdesc) <- cid
  colnames(mat) <- cid
  ## rdesc
  rdesc <- ssv[, !grepl('\\|', colnames(ssv))]
  rid <- rdesc$accessionNumber_VMsites_numVMsitesPresent_numVMsitesLocalizedBest_earliestVMsiteAA_latestVMsiteAA %>% gsub(' ', '', .)
  rownames(rdesc) <- rid
  
  ## assemble GCT
  gct <- new('GCT')
  gct@mat <- mat
  gct@cid <- cid
  gct@rid <- rid
  gct@rdesc <- rdesc
  gct@cdesc <- cdesc
  gct@src <- ssv.str
  
  write.gct(gct, ofile = sub('\\.ssv$','',ssv.str))
  
}


########################################################################
## 20160504 import ssv files generated by SpecMill
## - simplified version
########################################################################
read.ssv2 <- function(file, sep.cn="|", ...){

    ssv <- read.table(file, sep=';', fill=T, row.names=NULL, stringsAsFactors=F, quote='', comment.char='', skipNul=T, ...)

    ## check whether second line is part of the header
    n=ifelse( suppressWarnings( sum(is.na(as.numeric(ssv[2, ])))) == ncol(ssv), 2, 1 )

    ## column names
    ##cnames <- sub('\\|$','',apply(ssv[1:n, ], 2, paste, collapse='|'))
    cnames <- sub('(\\|$|^\\|)','',apply(ssv[n:1, ], 2, paste, collapse='|'))
    ssv <- ssv[-c(1:n), ]

    colnames(ssv) <- gsub(' ','|', cnames)

    return(ssv)
}
## ####################################################
##
##  export data frames to GCT 1.2
##  
##  gct   - data frame, two first columns contain annotations, 
##          remaining column contein expression values
##  file  - character, filename
##
## #####################################################
write.gct2 <- function(gct, ofile='tmp.gct', appenddim = T){

    ## ###################################
    ## gct format
    exprs <- gct[, 3:ncol(gct)]
    gct.tmp <- c('#1.2', paste(nrow(gct), ncol(exprs), sep ='\t'))
    gct.tmp <- c(gct.tmp,
                paste(colnames(gct), collapse='\t'),
                apply(gct, 1, paste, collapse='\t')
                )
    
    if(appenddim){
      ofile <- sub('\\.gct', '' , ofile)
      ofile <- paste0(ofile,'_n',paste0(rev(dim(exprs)), collapse = 'x'), '.gct')
      }
    writeLines( gct.tmp, ofile)
}

## ######################################################

