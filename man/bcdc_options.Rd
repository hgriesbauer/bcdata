% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bcdc_options.R
\name{bcdc_options}
\alias{bcdc_options}
\title{Retrieve options used in bcdata, their value if set and the default value.}
\usage{
bcdc_options()
}
\description{
This function retrieves bcdata specific options that can be set. These options can be set
using \code{option({name of the option} = {value of the option})}. The default options are purposefully
set conversatively to hopefully ensure successful requests. Resetting these options may result in
failed calls to the data catalogue. Options in R are reset everytime R is re-started. See examples for
addition ways to restore your initial state.
}
\details{
\code{bcdata.max_geom_pred_size} is the maximum size of an object used for a geometric operation. Objects
that are bigger than this value will have a bounding box drawn and apply the geometric operation
on that simpler polygon. Users can try to increase the maximum geometric predicate size and see
if the bcdata catalogue accepts their request.

\code{bcdata.chunk_limit} is an option useful when dealing with very large datasets. When requesting large objects
from the catalogue, the request is broken up into smaller chunks which are then recombined after they've
been downloaded. bcdata does this all for you but using this option you can set the size of the chunk
requested. On faster internet connections, a bigger chunk limit could be useful while on slower connections,
it is advisable to lower the chunk limit. Chunks must be less than 10000.
}
\examples{
\dontrun{
## Save initial conditions
original_options <- options()

## See initial options
bcdc_options()

options(bcdata.max_geom_pred_size = 1E6)

## See updated options
bcdc_options()

## Reset initial conditions
options(original_options)

}

}
