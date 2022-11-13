Nterm_mods_long <- c("Propionyl (Any N-term)", "Acetyl (Any N-term)")

Nterm_mods_short <- c("Pro-", "Ac-")

short_and_longhand_Nterm_mod_names <- cbind(Nterm_mods_long, Nterm_mods_short) %>%
  unlist() %>% #Generates a list initially and unfortunately you can't work with them very easily.
  data.frame()

usethis::use_data(short_and_longhand_Nterm_mod_names, overwrite = T)

