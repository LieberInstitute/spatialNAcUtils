#' Build stitched \code{SpatialExperiment}
#'
#' First, read in capture-area-level spaceranger outputs. Then, overwrite
#' spatial coordinates and images to represent group-level samples using
#' \code{sample_info$group} (though keep original coordinates in
#' \code{colData} columns ending in "_original"). Next, add info about
#' overlaps (via \code{spe$exclude_overlapping} and \code{spe$overlap_key}).
#' Ultimately, return a \code{SpatialExperiment} ready for visualization or
#' downstream analysis.
#'
#' @inheritParams add_array_coords
#' @inheritParams add_overlap_info
#' @param count_type A \code{character(1)} vector passed to \code{type} from
#' \code{SpatialExperiment::read10xVisium}, defaulting to "sparse"
#'
#' @return A \code{SpatialExperiment} object with one sample per group specified
#' in \code{sample_info} using transformed pixel and array coordinates (including
#' in the \code{spatialCoords}).
#'
#' @import SpatialExperiment
#' @importFrom readr read_csv
#' @importFrom dplyr mutate as_tibble
#' @export
#' @author Nicholas J. Eagles
#' 
#' @examples
#' #   For internal testing
#' \dontrun{
#'     sample_info = readr::read_csv('dev/test_data/sample_info.csv')
#'     coords_dir = 'dev/test_data'
#'     metric_name = 'sum_umi'
#'     spe = build_spe(sample_info, coords_dir, metric_name)
#' }

build_spe = function(sample_info, coords_dir, metric_name, count_type = "sparse") {
    message("Building SpatialExperiment using capture area as sample ID")
    spe <- read10xVisium(
        samples = dirname(sample_info$spaceranger_dir),
        sample_id = sample_info$capture_area,
        type = count_type,
        data = "raw",
        images = "lowres",
        load = FALSE
    )

    message("Overwriting imgData(spe) with merged images (one per group)")
    all_groups = unique(sample_info$group)

    img_data <- readImgData(
        path = file.path(coords_dir, all_groups),
        sample_id = all_groups,
        imageSources = file.path(
            coords_dir, all_groups, "tissue_lowres_image.png"
        ),
        scaleFactors = file.path(
            coords_dir, all_groups, "scalefactors_json.json"
        ),
        load = TRUE
    )

    coldata_fixed = colData(spe) |>
        dplyr::as_tibble() |>
        dplyr::mutate(
            capture_area = factor(sample_id),
            group = factor(
                sample_info$group[
                    match(capture_area, sample_info$capture_area)
                ]
            ),
            sample_id = group,
            barcode = colnames(spe),
            key = paste(barcode, capture_area, sep = "_")
        )

    spe <- SpatialExperiment(
        assays = assays(spe),
        rowData = rowData(spe),
        colData = coldata_fixed,
        spatialCoords = spatialCoords(spe),
        imgData = img_data
    )

    spe = add_array_coords(spe, sample_info, coords_dir, overwrite = TRUE)
    spe = add_overlap_info(spe, metric_name)

    return(spe)
}
