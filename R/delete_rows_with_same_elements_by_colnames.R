#' Delete rows that have the same values for a vector of specified column names.
#'
#' This function groups rows that have the same values for all the specified columns.
#' In addition to the primary function, it's also possible to specifiy if some species are not quantified
#' to exclude these species from being deleted. This works because if two rows have 'NA' values in all columns with 'abundance'
#' in it they will be retained. By default ignore_rows_where_all_abundances_NA, the parameter that controls this, is set to true.
#'
#'
#' @param df Any dataframe with column names.
#' @param vector_of_colnames Column names the user wishes to group rows by. If there is more than one row per group, these rows will be removed.
#' @param ignore_rows_where_all_abundances_NA Option to ignore any rows that have all 'NA' values in column names with 'abundance' in them. Defaults to FALSE.
#' @return The inputted \code{df} with rows removed as dictated by \code{vector_of_colnames}.
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @importFrom utils data
#' @export

delete_rows_with_same_elements_in_cols <- function(df, vector_of_colnames, ignore_rows_where_all_abundances_NA = F) {

  . <- NULL

 if (ignore_rows_where_all_abundances_NA == T) {

     modded_df <- df %>%
       dplyr::mutate(contains_all_NA_vals = is.na(dplyr::select(., dplyr::contains("abundance"))) %>%
                data.frame() %>%
                t() %>% #Transpose
                data.frame() %>%
                dplyr::summarise(dplyr::across(.cols = dplyr::everything(), ~ all(. == TRUE))) %>% #Apply the function all() to each column to check if all values are equal to TRUE. If this is the case, it will print TRUE.
                as.logical()) %>%
       dplyr::group_by(dplyr::across(dplyr::all_of(vector_of_colnames))) %>%
       dplyr::mutate(number_of_rows_per_group = dplyr::n()) %>%
       dplyr::ungroup() %>%
       dplyr::filter(.data$number_of_rows_per_group == 1 | .data$contains_all_NA_vals == TRUE)  %>%
       dplyr::select(-.data$number_of_rows_per_group, -.data$contains_all_NA_vals)

  } else {

   modded_df <- df %>%
     dplyr::group_by(dplyr::across(dplyr::all_of(vector_of_colnames))) %>%
     dplyr::mutate(number_of_rows_per_group = dplyr::n()) %>%
     dplyr::ungroup() %>%
     dplyr::filter(.data$number_of_rows_per_group == 1) %>%
     dplyr::select(-.data$number_of_rows_per_group)

 }

  return(modded_df)

}




