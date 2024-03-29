% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Adding_shorthand_PTM_names_to_sequences.R
\name{annotate_seq}
\alias{annotate_seq}
\title{Annotate a single peptide with its corresponding shorthand PTMs in the correct positions.}
\usage{
annotate_seq(sequence, notes, df_of_mods = PTM_info_df)
}
\arguments{
\item{sequence}{An unmodified sequence given as a string.}

\item{notes}{The text used to describe the modifications.}

\item{df_of_mods}{A dataframe of all the longhand and corresponding shorthand names for PTMs.}
}
\value{
Modified version of \code{sequence} with PTMs as dictated by \code{notes}.
}
\description{
Annotate a single peptide with its corresponding shorthand PTMs in the correct positions.
}
\examples{
annotate_seq("STELLIRKQRST", "Butyryl (K8); Methyl (R10)")
}
