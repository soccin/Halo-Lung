# socci@terra graphics$ more umapPanel01
# Row 1: CD45, CD8, CD11B, GFAP, OLIG2, SOX2
# socci@terra graphics$ more umapPanel02
# Row1: EGFR P_EGFR PTEN P_ERK P_S6_235 P_S6_240
# Row2: RB P_RB KI67


require(tidyverse)
require(readxl)

panels=read_xlsx("umap_marker_plotting_Lung.xlsx")
figCols=6
nPanels=ncol(panels)

for(pi in seq(nPanels)) {

    vv=panels[[pi]]
    vv=vv[!is.na(vv)]

    figRows=floor((seq(len(vv))-1)/figCols)+1
    panelFile=sprintf("umapPanel%02d",pi)
    if(fs::file_exists(panelFile)) fs::file_delete(panelFile)


    for(ri in unique(figRows)) {
        cat(paste0("Row",ri,":"),paste(vv[figRows==ri]),"\n")
        cat(paste0("Row",ri,":"),paste(vv[figRows==ri]),"\n",append=T,file=panelFile)
    }

}

