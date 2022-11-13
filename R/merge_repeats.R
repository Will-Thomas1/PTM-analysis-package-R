#' If two rows have the same sequence and modifications fields, this function will merge them.
#'
#' @param df_with_modifications_and_sequence_cols A dataframe with two columns called 'modifications' and 'sequence'.
#' @return Modified version of \code{df_with_modifications_and_sequence}.
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @export

merge_repeats <- function(df_with_modifications_and_sequence_cols){

  . <- NULL

  fun1 <- function(input){

    input %>%
      stringr::str_split("; ") %>% #Create a vector if an element contains ";".
      unlist() %>%
      base::unique() %>% #Identifies only unique strings in the vector.
      paste(collapse = "; ") #Puts the vector back again into one string.

  }


  fun2 <- function(input){
    purrr::map(input, fun1) %>%
      unlist()
  }


  funky <- df_with_modifications_and_sequence_cols %>%
    dplyr::group_by(.data$sequence, .data$modifications) %>% #In theory this should group rows if their sequence AND modifications columns are the same but in reality I don't think this worked.
    dplyr::summarise(dplyr::across(dplyr::everything(), ~trimws(paste(., collapse = "; ")))) %>% #Complicated code SHOULD condense every group into a single row.
    dplyr::ungroup() %>%
    dplyr::mutate(dplyr::across(.fns = fun2)) %>%#Removes duplicates WITHIN all cells
    utils::type.convert(., as.is = TRUE) #Before this step all the column classes were characters. This converts them into an appropriate form. Later code will break down if there are two different abundances for the same sequence AND modifications.

  return(funky)

}
