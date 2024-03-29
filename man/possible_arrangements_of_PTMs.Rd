% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/possible_arrangements_of_PTMs.R
\name{possible_arrangements_of_PTMs}
\alias{possible_arrangements_of_PTMs}
\title{For a sequence and specified amino acids with PTMs, display all possible arrangement of the aas + PTMs on the sequence.}
\usage{
possible_arrangements_of_PTMs(seq_without_mods, PTMs)
}
\arguments{
\item{seq_without_mods}{An unmodified sequence given as a string using the one letter amino acid nomenclature.}

\item{PTMs}{A string used to describe the aas and PTMs. E.g. 'KcrKmeRme2'}
}
\value{
Vector of modified \code{sequence}s with PTMs as dictated by \code{PTMs}.
}
\description{
For a sequence and specified amino acids with PTMs, display all possible arrangement of the aas + PTMs on the sequence.
}
\examples{
possible_arrangements_of_PTMs("KABCDKEFRKKADK", "Kme3RmeKpr")
}
