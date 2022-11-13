#Load data into env.

utils::data("short_and_longhand_Nterm_mod_names")
utils::data("PTM_info_df")

#Assign data as variables.

short_and_longhand_Nterm_mod_names <- get("short_and_longhand_Nterm_mod_names")
PTM_info_df <- get("PTM_info_df")

#Make all data's variables global variables for CMD check.

utils::globalVariables(names(c(PTM_info_df, short_and_longhand_Nterm_mod_names)))
utils::globalVariables(".")

#' Annotate a single peptide with its corresponding shorthand PTMs in the correct positions.
#'
#' @param sequence An unmodified sequence given as a string.
#' @param notes The text used to describe the modifications.
#' @param df_of_mods A dataframe of all the longhand and corresponding shorthand names for PTMs.
#' @return Modified version of \code{sequence} with PTMs as dictated by \code{notes}.
#' @examples
#' annotate_seq("STELLIRKQRST", "Butyryl (K8); Methyl (R10)")
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @importFrom utils data
#' @export

annotate_seq <- function(sequence, notes, df_of_mods = PTM_info_df){


  if (is.na(notes) == TRUE) { #If there is nothing in the notes field, simply return the sequence.
    return(sequence)
  } else {

    Positions_of_mods <- stringr::str_extract_all(notes, "\\(?[A-Z]+[0-9]+\\)?") %>% #Capture a capital letter followed by a number as well as anything else 'connected' before a space appears in the mods variable.
      unlist() %>% #List to vector.
      stringr::str_remove_all("\\(") %>%
      stringr::str_remove_all("\\)") %>% #Not the most elegant code but it still works. Removes brackets from the list.
      data.frame() %>%
      stats::setNames("bothcols") %>% #Need to rename to column as it currently doesn't have a name.
      tidyr::separate(.data$bothcols,
               into = c("Amino_acid", "position"),
               sep = "(?<=[A-Z])(?=[0-9])") #This regex means the separation should take place between any capital letter followed by a number.


    PTMs_to_search_for <- paste(df_of_mods$PTMs_long, collapse = "|") %>% #Takes the longhand version of names and creates a regex entry that searches for PTM A or PTM B or ....
      stringr::str_replace(., "(?<=^)(?=.)", "\\(") %>% #Add brackets for regex used in the next step. (PTMA|PTMB)
      stringr::str_replace(., "(?<=.)(?=$)", "\\)") %>%
      paste(., "(?=([A-Z]|\\s)+\\([A-Z][0-9]+)", sep = "") #Lookahead for any number of capital letters or whitspaces followed by an opening bracket, a capital letter and 1 or more numbers.


    PTMs_present <- stringr::str_extract_all(notes, PTMs_to_search_for) %>% #This code will create a list in the form of a dataframe of the modifications present in sequential order.
      unlist() %>% #List to vector.
      data.frame() %>%
      stats::setNames("PTMs_long") #Adds a title "PTMs_long"

    Residue_mod_and_position <- dplyr::left_join(PTMs_present, df_of_mods, by = "PTMs_long") %>% #This merges the two data frames, using 'PTMs_long' as a filter
      dplyr::select("PTMs_short") %>% #Only retains the abbreviated form of the modifications.
      dplyr::mutate(Positions_of_mods, PTMs_short = .$PTMs_short) %>% #Adds a new column in the Positions_of_mods dataframe called PTMs_short which uses the previous values generated as its observed values. Need to use the $ sign as the previous code actually creates a dataframe (which can be a column if its width is 1).
      tidyr::unite(.data$Amino_acid, .data$PTMs_short, col = "residue", sep = "") %>% #Merges the columns that contain the information about the amino acid and the shorthand modification. The position in the seq is also known.
      dplyr::mutate(position = as.numeric(position)) #Converts the position column to a number (double in this case)

    no_of_chars <- nchar(sequence) #Counts the number of characters in the sequence without mods.

    position <- c(1:no_of_chars) #Pipes doesn't work here so need to create a new vector that counts from 1 to the number of characters in the sequence.

    residues_and_positions <- sequence %>%
      strsplit(., "") %>% #Separate each character in the sequence.
      cbind.data.frame(., position)  #Standard cbind doesn't work here. Creates a df.

    colnames(residues_and_positions)[1] <- "residue"

    `%notin%` <- Negate(`%in%`) # %in% denotes that the following is a vector.

    new_seq_messy <- residues_and_positions %>%
      dplyr::filter(position %notin% Residue_mod_and_position$position) %>%
      dplyr::bind_rows(Residue_mod_and_position) %>% #Adds rows that contain info on the modified lysines.
      dplyr::arrange(position) #To start with the added rows will be at the bottom so this puts everything back in order.

    new_seq_clean <- new_seq_messy$residue %>%
      paste(collapse = "")

    return(new_seq_clean)
  }
}

#' Adds a new column with modified sequences that include relevant PTMs called "sequence_modfified".
#'
#' Note that for the moment it is not possible to change the title names. The title names must be "modifications" and "sequence". Sheet name does not need quotation marks.
#'
#' @param df_with_sequences_and_modifications An optional parameter. If you don't want to import a dataframe directly from an Excel sheet but have an R dataframe instead, enter the object's name here.
#' @param residues_to_mark_as_unmodified An optional parameter. If you enter the shorthand code of a residue, e.g. "K", all sequences will show "Kunmod".
#' @param add_Nterm_mods Option to label N-terminally modified sequences if indicated in the modifications field. Uses the short_and_longhand_Nterm_mod_names inbuilt dataframe. Defaults to FALSE.
#' @return Dataframe with a new column called 'sequence_modified'.
#' @export

add_seq_info <- function(df_with_sequences_and_modifications, residues_to_mark_as_unmodified, add_Nterm_mods = F){

  if (missing(df_with_sequences_and_modifications)) {

  sheet_of_interest <- readline(prompt = "Please enter the name of the sheet that you want to analyse: ")

  exceldata <- file.choose() %>%
    readxl::read_excel(sheet = sheet_of_interest)

  dfdata <- data.frame(exceldata) #Convert file from .xlsx to .df.

  } else {
    dfdata <- df_with_sequences_and_modifications
  }

  sequence_vector <- dfdata$sequence #Create a vector with only the sequences

  modifications_vector <- dfdata$modifications  #Create a vector with only the modifications
  #Very important step! Code won't work otherwise
  #Add modified sequences as a new column. For some reason cbind() doesn't work.

  dfdata <- dfdata %>%
    dplyr::mutate(sequence_modified = furrr::future_map2(sequence_vector, modifications_vector, annotate_seq) %>% #Maps the two vectors onto the function annotate_seq() giving a new output which is subsequently added as a new column.
                    unlist())  #This step is important in coverting the column from a list to a vector of characters.

  if (missing(residues_to_mark_as_unmodified)) {

    dfdata <- dfdata

  } else {

    dfdata <- add_unmod_qualifier(dfdata, "sequence_modified", residues_to_mark_as_unmodified)

  }

  if (add_Nterm_mods == T) {

    dfdata <- add_Nterm_mods(dfdata)
  }

  return(dfdata)

}

#' Labels unmodified residues for PTM labelled sequences in a dataframe.
#'
#' For a given column name and residues, all strings are modified where specified residues that with no PTMs are marked as unmodified. . E.g. "K" would become "Kun" while "Kac" would stay the same. This function should only be applied after "annotate_seq".
#'
#' @param df_with_modified_seqs A dataframe object that has a column with shortand peptide sequences and PTMs.
#' @param colname_with_modified_seqs  The column name for strings with shortand peptide sequences and PTMs. Given as a string. Defaults to "sequence_modified".
#' @param residues What residues should be marked as 'un'. Can be inputted as a single character, e.g. "K" or as a vector.
#' @return A modified column where all strings are modified with specified residues that don't have any PTMs marked as unmodified.
#' @importFrom data.table :=
#' @export

add_unmod_qualifier <- function(df_with_modified_seqs, colname_with_modified_seqs = "sequence_modified", residues) {

  sequence_mod_vector <- df_with_modified_seqs[[colname_with_modified_seqs]]

  output <- df_with_modified_seqs %>%
    dplyr::mutate(!! colname_with_modified_seqs := furrr::future_map2(sequence_mod_vector, residues, add_unmod_qualifier_1seq) %>%
                     unlist())

  return(output)

}

#' Adds Nterm modifications if any are present at the LHS of a sequence.
#'
#' Looks at the modifications field of a row and based on the package's inbuilt dataframe, finds its shorthand equivalent. This shorthand text is then appended to the LHS of the sequence in the same row.
#'
#' @param df A dataframe object that has at least two columns which describe the peptide sequence and modifications it has respectively.
#' @param sequence_colname The column name for strings with peptide sequences.
#' @param modifications_colname The column name for strings with descriptions of the PTMs present.
#' @param Nterm_mods_df A dataframe with two columns: one for strings which describe the N-terminal modification and the other for the corresponding shorthand string.
#' @return A modified column where all sequences are now 'labelled' if their N-terminus is modified, if appropriate.
#' @export

add_Nterm_mods <- function(df, sequence_colname = "sequence_modified", modifications_colname = "modifications", Nterm_mods_df = short_and_longhand_Nterm_mod_names){

  add_N_term_mods_1seq_vectorised <- Vectorize(add_N_term_mods_1seq, vectorize.args = c("sequence", "modifications_text"), SIMPLIFY = TRUE, USE.NAMES = TRUE)

  df_with_Nterm_mods <- df %>%
    dplyr::mutate(!! sequence_colname := add_N_term_mods_1seq_vectorised(df[[sequence_colname]], df[[modifications_colname]], Nterm_mods_df))

}

#Helpers

add_unmod_qualifier_1seq <- function(sequence_modified, residues) {

. <- NULL

regex <- paste(residues, collapse = "|") %>%
  stringr::str_replace(., "(?<=^)(?=.)", "\\(") %>% #Add brackets for regex used in the next step. (PTMA|PTMB)
  stringr::str_replace(., "(?<=.)(?=$)", "\\)\\(?![a-z]\\)")

new_sequence_modified <- stringr::str_replace_all(sequence_modified, regex, "\\1un")

}


add_N_term_mods_1seq <- function(sequence, modifications_text, Nterm_mods_df = short_and_longhand_Nterm_mod_names){

  . <- NULL

  Nterm_mods_df <- data.table::data.table(Nterm_mods_df) #Make the dataframe a data.table object.

  regex <- paste(Nterm_mods_df$Nterm_mods_long, collapse = "|") %>%
    stringr::str_replace_all(., "\\(", "\\\\(") %>%
    stringr::str_replace_all(., "\\)", "\\\\)")

  Nterm_mod_found <- stringr::str_extract(modifications_text, "^(.+?)(;|$)") %>% #Improve performance by only looking where the text is going to be found. ? is used to make the regex non-greedy. Sometimes description will only be Nterm modification, which is why |$ is needed.
    stringr::str_extract(., regex)

  if (is.na(Nterm_mod_found)) {

    new_sequence <- sequence

  } else {

    corresponding_Nterm_abbrev <- Nterm_mods_df[Nterm_mods_long == Nterm_mod_found
    ][, Nterm_mods_short]

    new_sequence <- stringr::str_replace(sequence, "(?<=^)(?=.)", corresponding_Nterm_abbrev) #Replace start of sequence with shorthand version

  }

  return(new_sequence)

}







