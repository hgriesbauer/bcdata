% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bcdc_search.R
\name{bcdc_get_record}
\alias{bcdc_get_record}
\title{Show a single B.C. Data Catalogue record}
\usage{
bcdc_get_record(id)
}
\arguments{
\item{id}{the human-readable name, permalink ID, or
URL of the record.

It is advised to use the permament ID for a record rather than the
human-readable name to guard against future name changes of the record.
If you use the human-readable name a warning will be issued once per
session. You can silence these warnings altogether by setting an option:
\code{options("silence_named_get_record_warning" = TRUE)} - which you can put
in your .Rprofile file so the option persists across sessions.}
}
\value{
A list containing the metadata for the record
}
\description{
Show a single B.C. Data Catalogue record
}
\examples{
\dontrun{
bcdc_get_record("https://catalogue.data.gov.bc.ca/dataset/bc-airports")
bcdc_get_record("bc-airports")
bcdc_get_record("https://catalogue.data.gov.bc.ca/dataset/76b1b7a3-2112-4444-857a-afccf7b20da8")
bcdc_get_record("76b1b7a3-2112-4444-857a-afccf7b20da8")
}
}
