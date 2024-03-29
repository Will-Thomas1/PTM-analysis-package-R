% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{PTM_info_df}
\alias{PTM_info_df}
\title{PTM's longhand and shorthand names.}
\format{
A data frame with 8 rows and 2 variables:
\describe{
\item{PTMs_long}{longhand name of PTM, string}
\item{PTMs_short}{shorthand name of PTM, string}
\item{shift_in_MW}{shift in MW compared to native residue, integer}
\item{aas_that_can_by_modified}{amino acids that can be modified by this PTM, string}
}
}
\usage{
PTM_info_df
}
\description{
A tibble containing a Post Translational Modification's longhand and corresponding shorthand name. This is not an exhaustive list and can be modified by the user to suit their needs. This is most easily done by using the 'editData' function. Note the PTMs listed do NOT have a corresponding specific residue.
}
\keyword{datasets}
