#' Create new columns with relative abundances by dividing the abundance for one row by the sum of the total abundace.
#'
#' If the abundance_colnames parameter is left blank then all column headers with 'abundance' in them will be chosen.
#' New columns generated will have the same name as the ones they're derived from except they'll have '_relative' appended at the end.
#'
#' @param df A dataframe with different sample abundance values.
#' @param abundance_colnames A vector of column names.
#' @return The original df with new columns with relative abundance values.
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @export

add_relative_abundance <- function(df, abundance_colnames) {

  #Choose all colnames with 'abundance' if abundance_colnames arguement is not defined.

  if(missing(abundance_colnames)) {

    abundance_colnames <- df %>%
      dplyr::select(dplyr::contains("abundance")) %>%
      colnames(.)

  }

  #Apply add_relative_abundance_for_1col function to all columns in abundance_colnames.

  for (i in 1:length(abundance_colnames)) {

    df <- df %>%
      add_relative_abundance_for_1col(., abundance_colnames[i])

  }

  return(df)

}

###Helper function

add_relative_abundance_for_1col <- function(df, abundance_colname){

  relative_abundance_colname <- paste(abundance_colname, "_relative", sep = "")

  df_with_specified_seq_and_rel_abundances <- df %>%
    dplyr::mutate(!!relative_abundance_colname  := (.[[abundance_colname]] /  sum(.[abundance_colname], na.rm = TRUE))) #!! removes quotes, := allows the name of the column to be 'dynamic'.

  return(df_with_specified_seq_and_rel_abundances)

}
