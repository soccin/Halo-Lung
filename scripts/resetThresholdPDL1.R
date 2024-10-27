#######################################################################
argv=commandArgs(trailing=T)

if(length(argv)<2) {
  cat("\n\n")
  cat("   usage: resetThresholdPDL1.R reassign.RDA newPDL1Threshold\n")
  cat("\n\n")
  quit()
}

require(tidyverse)
rdaRootFolder=argv[1]
cellDiveId=argv[2]
rdaFile=fs::dir_ls(rdaRootFolder,regex=cc(cellDiveId,"__Halo"))

newPDL1Threshold=argv[3]

rdaOutputFolder="rda/v6_04_Reset"

if(newPDL1Threshold=="NA") {
  cat("\n\nNew threshold is `NA`; just copying the original rda file\n\n")
  fs::dir_create(rdaOutputFolder)
  fs::file_copy(rdaFile,fs::path(rdaOutputFolder,basename(rdaFile)),overwrite=T)
  quit()
}

newPDL1Threshold=as.numeric(newPDL1Threshold)

oo=readRDS(rdaFile)

thetaOrig=oo$thetas %>%
  filter(Marker=="PDL1") %>%
  pull(dye_cyto_positive_threshold_weak)


metaData=list(theta_PLD1_orig=thetaOrig)
oo$metadata$resetThetaPDL1=metaData

oo$thetas=oo$thetas %>%
  rows_update(
    tibble(
      Marker="PDL1",
      dye_cyto_positive_threshold_weak=newPDL1Threshold
    ),by="Marker"
  )

if(newPDL1Threshold<thetaOrig) {
  resetTbl=oo$marker.data %>%
    filter(Marker=="PDL1") %>%
    select(UUID,Positive_Classification,TIntensity) %>%
    mutate(Positive_Classification=ifelse(TIntensity>newPDL1Threshold,1,Positive_Classification)) %>%
    select(-TIntensity)
} else {
  resetTbl=oo$marker.data %>%
    filter(Marker=="PDL1") %>%
    select(UUID,Positive_Classification,TIntensity) %>%
    mutate(Positive_Classification=ifelse(TIntensity<newPDL1Threshold,0,Positive_Classification)) %>%
    select(-TIntensity)
}

oo$marker.data=oo$marker.data %>%
  mutate(Positive_Classification.orig2=Positive_Classification) %>%
  rows_update(resetTbl,by="UUID")

stats=oo$marker.data %>%
  filter(Marker=="PDL1") %>%
  select(UUID,Marker,Positive_Classification.orig2,Positive_Classification) %>%
  count(Positive_Classification.orig2,Positive_Classification) %>%
  rename(ORIG=Positive_Classification.orig2,RESET=Positive_Classification) %>%
  mutate(CellDive_ID=oo$sample.data$CellDive_ID,Patient_ID=oo$sample.data$Patient_ID)

fs::dir_create("out/resetPDL1")
write_csv(stats,fs::path("out/resetPDL1",cc(cellDiveId,"_resetPDL1_stats.csv")))

fs::dir_create(rdaOutputFolder)
saveRDS(oo,fs::path(rdaOutputFolder,basename(rdaFile)),compress=T)


