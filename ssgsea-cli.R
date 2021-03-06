#!/usr/bin/env Rscript
options( warn = -1 )
suppressPackageStartupMessages(library("optparse"))

# parse the directory this file is located
if(is.na(commandArgs()[4])){
  # library(rstudioapi)    
  # this.file.dir <- rstudioapi::getActiveDocumentContext()$path
  this.file.dir <- sys.frame(tail(grep('source',sys.calls()),n=1))$ofile
}else{
  this.file.dir <- commandArgs()[4]
}
# this.file <- sys.frame(tail(grep('source',sys.calls()),n=1))$ofile
# this.file.dir <- dirname(this.file)
this.file.dir <- sub('^(.*(/|\\\\)).*', '\\1', sub('.*?\\=','', this.file.dir))
cat('DIRECTORY: ',this.file.dir, '\n')

# specify command line arguments
option_list <- list(
  make_option( c("-i", "--input"), action='store', type='character',  dest='input.ds', help='Path to input GCT file.'),
  make_option( c("-o", "--ouptut"), action='store', type='character',  dest='output.prefix', help='File prefix for output files.', default='out'),
  make_option( c("-d", "--db"), action='store', type='character',  dest='gene.set.databases', help='Path to gene set database (GMT format).'),
  make_option( c("-n", "--norm"), action='store', type='character',  dest='sample.norm.type', help='Sample normalization: "rank", "log", "log.rank" or "none".', default = 'rank'),
  make_option( c("-w", "--weight"), action='store', type='numeric',  dest='weight', help='When weight==0, all genes have the same weight; if weight>0 actual values matter and can change the resulting score.', default = 0.75),
  make_option( c("-c", "--correl"), action='store', type='character',  dest='correl.type', help='Correlation type: "rank", "z.score", "symm.rank".', default = 'z.score'),
  make_option( c("-t", "--test"), action='store', type='character',  dest='statistic', help='Test statistic: "area.under.RES", "Kolmogorov-Smirnov"', default = 'area.under.RES'),
  make_option( c("-s", "--score"), action='store', type='character',  dest='output.score.type', help='Score type: "ES" - enrichment score,  "NES" - normalized ES', default = 'NES'),
  make_option( c("-p", "--perm"), action='store', type='numeric',  dest='nperm', help='Number of permutations', default = 1000),
  make_option( c("-m", "--minoverlap"), action='store', type='numeric',  dest='min.overlap', help='Minimal overlap ebtween signature and data set.', default = 10),
  #make_option( c("-f", "--fdr"), action='store', type='logical',  dest='fdr.pvalue', help='Report FDR-corrected p-values.', default = TRUE),
  make_option( c("-e", "--export"), action='store', type='logical',  dest='export.signat.gct', help='For each signature export expression GCT files.', default = TRUE),
  make_option( c("-g", "--globalfdr"), action='store', type='logical',  dest='global.fdr', help='If TRUE global FDR across all data columns is calculated.', default = FALSE),
  make_option( c("-u", "--cores"), action='store', type='numeric',  dest='use.cores', help='Number of cores to use; Set to 1 to not run in parallel mode', default = 1)
  )

# parse command line parameters
opt <- parse_args( OptionParser(option_list=option_list) )
if(opt$use.cores == 1){par <- FALSE}
if(opt$use.cores > 1){par <- TRUE}
# hard-coded parameters
# spare.cores <- 0 # use all available cpus
log.file <- paste(opt$output.prefix, '_ssgsea.log.txt', sep='')

## #####################################
## source the actual script
source(paste(this.file.dir, 'R/ssGSEA2.0.R', sep=''))

## ######################################################################################################
##
##                   run ssGSEA
##
## ######################################################################################################
res <- ssGSEA2(
	input.ds=opt$input.ds,
	output.prefix=opt$output.prefix,
	gene.set.databases=opt$gene.set.databases,
  sample.norm.type=opt$sample.norm.type,
	weight=opt$weight,
	statistic=opt$statistic,
	output.score.type=opt$output.score.type,
	nperm=opt$nperm,
	min.overlap=opt$min.overlap,
  correl.type=opt$correl.type,
	export.signat.gct=opt$export.signat.gct,
#	fdr.pvalue=opt$fdr.pvalue,
	global.fdr=opt$global.fdr,
  par=par,
  use.cores=opt$use.cores,
  log.file=log.file
)



