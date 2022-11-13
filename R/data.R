#' PTM's longhand and shorthand names.
#'
#' A tibble containing a Post Translational Modification's longhand and corresponding shorthand name. This is not an exhaustive list and can be modified by the user to suit their needs. This is most easily done by using the 'editData' function. Note the PTMs listed do NOT have a corresponding specific residue.
#'
#' @format A data frame with 8 rows and 2 variables:
#' \describe{
#'   \item{PTMs_long}{longhand name of PTM, string}
#'   \item{PTMs_short}{shorthand name of PTM, string}
#'   \item{shift_in_MW}{shift in MW compared to native residue, integer}
#'   \item{aas_that_can_by_modified}{amino acids that can be modified by this PTM, string}
#' }
"PTM_info_df"

#' N-terminal modification's longhand and shorthand names.
#'
#' A tibble containing a N-terminal modification's longhand and corresponding shorthand name. This is not an exhaustive list and can be modified by the user to suit their needs. This is most easily done by using the 'editData' function.
#'
#' @format A data frame with 2 rows and 2 variables:
#' \describe{
#'   \item{Nterm_mods_long}{longhand name of N-terminal modification, string}
#'   \item{Nterm_mods_short}{shorthand name of N-terminal modification, string}
#' }
"short_and_longhand_Nterm_mod_names"
