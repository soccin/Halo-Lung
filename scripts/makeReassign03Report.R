require(tidyverse)
require(openxlsx)

dA=fs::dir_ls("out/reassign/03",regex="stats.*Reassign03_A.*.csv") %>% map(read_csv,col_types = cols(.default = "c")) %>% bind_rows %>% type_convert
dB=fs::dir_ls("out/reassign/03",regex="stats.*Reassign03_B.*.csv") %>% map(read_csv,col_types = cols(.default = "c")) %>% bind_rows %>% type_convert

rpt=dB %>%
    full_join(dA %>% select(Sample,FOV,Total) %>% distinct) %>% 
    arrange(gsub("L_","",Sample) %>% gsub("[^0-9]","",.) %>% as.numeric)

write.xlsx(list(FOV=rpt),"rpt_Reassign03_A.xlsx")
