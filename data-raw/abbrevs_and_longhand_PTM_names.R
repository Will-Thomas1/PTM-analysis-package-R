PTMs_long <- c("Methyl","Dimethyl","Trimethyl","Propionyl", "Acetyl","Lactyl_DP","Butyryl","Crotonyl","Succinyl","2-hydroxyisobutyryl", "β-hydroxybutyryl", "Phosphoryl")

PTMs_short <- c("me1","me2","me3","pro","ac","lac","bu","cr","succ","hib","bhb","ph")

shift_in_MW <- c(14, 28, 42, 56, 42, 72, 70, 68, 100, 86, 86, 80)

aas_that_can_by_modified <- c("K; R", "K; R", "K", "K", "K", "K", "K", "K", "K", "K", "K", "K; R")

PTM_info_df <- cbind(PTMs_long, PTMs_short, shift_in_MW, aas_that_can_by_modified) %>%
  unlist() %>% #Generates a list initially and unfortunately you can't work with them very easily.
  data.frame()

usethis::use_data(PTM_info_df, overwrite = T)



