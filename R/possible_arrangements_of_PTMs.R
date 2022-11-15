#' For a sequence and specified amino acids with PTMs, display all possible arrangement of the aas + PTMs on the sequence.
#'
#' @param seq_without_mods An unmodified sequence given as a string using the one letter amino acid nomenclature.
#' @param PTMs A string used to describe the aas and PTMs. E.g. 'KcrKmeRme2'
#' @return Vector of modified \code{sequence}s with PTMs as dictated by \code{PTMs}.
#' @examples
#' possible_arrangements_of_PTMs("KABCDKEFRKKADK", "Kme3RmeKpr")
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @importFrom utils data
#' @export

possible_arrangements_of_PTMs <- function(seq_without_mods, PTMs) {


  seq_of_interest_and_positions <- seq_without_mods %>%
    stringr::str_extract_all(., "[A-Z]") %>%
    unlist() %>%
    data.frame(residue = .) %>%
    dplyr::mutate(position = c(1:length(.data$residue)))

  potential_mod_residues <- stringr::str_extract_all(PTMs, "[A-Z]") %>%
    unlist() %>%
    unique()

  modifiable_positions <- paste(seq_of_interest_and_positions$residue, seq_of_interest_and_positions$position, sep = "") %>%
    stringr::str_subset(., paste(potential_mod_residues, sep = "", collapse = "|"))

  PTMs_in_combo <- PTMs %>%
    stringr::str_extract_all(., "[A-Z][a-z]+[0-9]?") %>%
    unlist()

  positions_modified_combo <- utils::combn(modifiable_positions, length(PTMs_in_combo)) %>%
    data.frame()

  permns_PTM_order <- combinat::permn(PTMs_in_combo) %>%
    data.frame() %>%
    stats::setNames(c(1:ncol(.)))

  all_permns_and_positions <- permns_PTM_order %>%
    t() %>%
    data.frame() %>%
    tidyr::unite(., col = 'all_PTMs_and_positions', dplyr::everything(), sep = "") %>%
    dplyr::filter(!stringr::str_detect(.data$all_PTMs_and_positions, "([A-Z])(?!([0-9]+|[a-z])(\\1|[a-z0-9]))")) %>%
    subset(drop = TRUE)

  #Get all perms and places in the sequence

  PTM_positions <- as.numeric()

  for (i in 1:ncol(positions_modified_combo)) {
    fatto <- permns_PTM_order %>%
      dplyr::summarise(dplyr::across(dplyr::everything(), ~ paste(positions_modified_combo[[i]], ., sep = ""))) #Paste the contents of positions_modified_combo into each row

    PTM_positions <- c(PTM_positions, fatto %>%
                         t() %>% #Transpose dataframe so now there's only one column
                         data.frame() %>%
                         tidyr::unite(., col = 'all_PTMs_and_positions', dplyr::everything(), sep = "") %>% #Merges all columns into one
                         dplyr::filter(!stringr::str_detect(.data$all_PTMs_and_positions, "([A-Z])(?!([0-9]+|[a-z])(\\1|[a-z]))")) %>% #Filter out any instances where the PTM is mismatched to the residue e.g. K1Rme.
                         subset(drop=TRUE)) %>% #Convert dataframe to a vector
      stringr::str_remove_all(., "(?<=[0-9])[A-Z](?=[a-z])") #Get rid of the 'secondary residues'. E.g. goes from K1Kme3 to K1me3
  }

  PTM_positions



  final_output <- as.numeric()

  for (i in PTM_positions) {

    final_output <- c(final_output, add_mods_to_seq(i, seq_without_mods))
  }

  final_output <- final_output %>%
    unique() #Gets rid of duplicate sequences

  return(final_output)

}

#Helpers

add_mods_to_seq <- function(position_of_mods, seq_without_mods) {

  seq_of_interest_and_positions <- seq_without_mods %>%
    stringr::str_extract_all(., "[A-Z]") %>%
    unlist() %>%
    data.frame(residue = .) %>%
    dplyr::mutate(position = c(1:length(.data$residue)))

  positions_and_mods_df <- data.frame(stringr::str_extract_all(position_of_mods, "(?<=[A-Z])[0-9]+(?=[a-z])")) %>%
    stats::setNames("position") %>%
    dplyr::mutate(residue = stringr::str_extract_all(position_of_mods, "[A-Z]") %>% unlist()) %>%
    dplyr::mutate(mod = stringr::str_extract_all(position_of_mods, "(?<=[0-9])[a-z]+([0-9]+)?(?=([A-Z]|$))") %>% unlist()) %>%
    tidyr::unite(., .data$residue, .data$mod, col = "residue", sep = "") %>%
    utils::type.convert(., as.is = TRUE)


  positions_plus_mods_final <- dplyr::select(seq_of_interest_and_positions, .data$position, .data$residue) %>%
    dplyr::anti_join(., positions_and_mods_df, by = "position") %>%
    dplyr::bind_rows(positions_and_mods_df) %>%
    dplyr::arrange(., .data$position)

  return(paste(positions_plus_mods_final$residue, collapse = ""))

}
