#' Function to calculate the average number of PTMs per sequence, weighted by abundance.
#'
#' @param df_with_annotated_seqs A dataframe with at least two columns: one with modified sequences that have shorthand PTMs and another with abundance.
#' @param all_PTMs A vector with all the PTMs of interest. E.g. c("Kcr", "Kac").
#' @param abundance The title of the column for abundance, given as a string. If this parameter is left empty
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @export
Avg_no_of_PTMs <- function(df_with_annotated_seqs, all_PTMs, abundance){

  . <- NULL #Need to set . to a NULL value otherwise it'll be recognised as a global parameter that hasn't been set a value.

  PTMs_of_interest <- all_PTMs %>% #Creates a string that goes like: "Kbu|Kcr|Kme|etc.".
    paste(collapse = "|")

  half_the_solution <- df_with_annotated_seqs$sequence_modified %>% #This code counts the number of times a PTM of interest appears in a sequence
    stringr::str_extract_all(PTMs_of_interest) %>%
    stringr::str_count(pattern = "([A-Z])")#Took way too long to figure it out but lengths() doesn't give a vector you can work with.

  df_with_no_PTMs_per_seq <- dplyr::mutate(df_with_annotated_seqs, No_of_PTMs = half_the_solution)

  sum_abundance_times_PTM_freq <- df_with_no_PTMs_per_seq %>%
    dplyr::mutate(abundance_times_PTM_freq = .[abundance]*.data$No_of_PTMs) %>%
    dplyr::summarise(sum(.data$abundance_times_PTM_freq, na.rm = TRUE))

  sum_abundance <- df_with_annotated_seqs %>%
    dplyr::summarise(sum(.[abundance], na.rm = TRUE))

  Average_no_of_PTMs <- sum_abundance_times_PTM_freq/sum_abundance

  Average_no_of_PTMs <- signif(Average_no_of_PTMs, digits = 3) %>%
    stats::setNames(paste("Average", all_PTMs, "abundance per sequence"))

  return(Average_no_of_PTMs)
}

