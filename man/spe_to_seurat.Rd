% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/spe_to_seurat.R
\name{spe_to_seurat}
\alias{spe_to_seurat}
\title{Convert a \code{SpatialExperiment} object to a \code{Seurat} object}
\usage{
spe_to_seurat(spe, verbose = TRUE)
}
\arguments{
\item{spe}{A \code{SpatialExperiment} with colData columns \code{in_tissue},
\code{array_row_transformed}, \code{array_col_transformed},
\code{pxl_row_in_fullres_transformed}, and \code{pxl_col_in_fullres_transformed}}

\item{verbose}{A logical(1) vector. If true, print status updates about the
conversion process}
}
\value{
A \code{Seurat} object
}
\description{
Given a \code{SpatialExperiment} object, first \code{as.Seurat()} is run,
which operates on \code{SingleCellExperiment} objects. The remaining
components (images, spatial coordinates) are added manually. The actual
appearance of images are buggy for now.
}
\examples{

#   Grab an example SpatialExperiment and add dummy "transformed" versions of
#   spatial coordinates, which are to be converted
spe <- if (!exists("spe")) {
    spatialLIBD::fetch_data(type = "spatialDLPFC_Visium_example_subset")
}
spe$array_row_transformed <- spe$array_row
spe$array_col_transformed <- spe$array_col
spe$pxl_row_in_fullres_transformed <- SpatialExperiment::spatialCoords(spe)[, "pxl_row_in_fullres"]
spe$pxl_col_in_fullres_transformed <- SpatialExperiment::spatialCoords(spe)[, "pxl_col_in_fullres"]
colnames(spe) <- spe$key

#   Convert
seur <- spe_to_seurat(spe)
}
\author{
Nicholas J. Eagles
}
