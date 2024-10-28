require(tidyverse)

get_pdl1_pos_stats <- function(fi) {
    oo=readRDS(fi)
    mm=oo$marker.data %>%
      select(UUID,Marker,matches("Pos")) %>%
      filter(Marker=="PDL1")
    aa=readRDS(
      fs::dir_ls(
        "rda/v6_Atlas/BySample",
        regex=gsub("_Halo.*","",basename(fi))
       )
    )

  left_join(mm,aa) %>% 
    group_by(Marker,Cell_type) %>%
    summarize(PCT.PDL1=mean(Positive_Classification)) %>%
    mutate(
      Patient_ID=oo$sample.data$Patient_ID,
      CellDive_ID=oo$sample.data$CellDive_ID
    )
  
}



