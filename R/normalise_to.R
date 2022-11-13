#' Creates new columns that are normalised to a specified column with abundance values.
#'
#' @param df A dataframe with different sample abundance values.
#' @param reference_col The column name of the abundance values that will become the 'reference values', given as a string.
#' @param comparison_cols A vector of column names to normalise.
#' @return The original df with new columns with normalised abundance values.
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @export

normalise_to <- function(df, reference_col, comparison_cols){

  new_col_names <- comparison_cols %>% #Make new col names
    paste(., "/", reference_col, sep = "")

  for (i in 1:length(comparison_cols)) {

    df <- df %>%
      dplyr::mutate(!!new_col_names[i] := .[comparison_cols][[i]]/.[[reference_col]])

  }

  return(df)

}
