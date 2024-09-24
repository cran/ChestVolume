#' Example Chest Segment Definition
#'
#' This dataset defines chest segmentations using 3D markers. It is a list containing
#' five elements: the first element is a vector of marker names, and the remaining
#' four elements define markers assigned to four chest segments: UL (Upper Left),
#' UR (Upper Right), LL (Lower Left), and LR (Lower Right).
#'
#' @format A list with 5 elements:
#' \describe{
#'   \item{Marker Names}{A character vector of marker names.}
#'   \item{UL}{A character vector of marker names included in the upper left (UL) chest segment.}
#'   \item{UR}{A character vector of marker names included in the upper right (UR) chest segment.}
#'   \item{LL}{A character vector of marker names included in the lower left (LL) chest segment.}
#'   \item{LR}{A character vector of marker names included in the lower right (LR) chest segment.}
#' }
#'
#' @details This dataset is used to demonstrate how markers can be grouped into segments
#' based on their positions on the chest. The segmentation divides the chest into four
#' quadrants: UL (Upper Left), UR (Upper Right), LL (Lower Left), and LR (Lower Right).
#'
#' @examples
#' # Load the dataset
#' data(Segment_example)
#'
#' # View the structure of the dataset
#' str(Segment_example)
#'
#' # Extract the marker names
#' marker_names <- Segment_example[[1]]
#'
#' # Extract markers for the upper left (UL) segment
#' UL_markers <- Segment_example$UL
#'
"Segment_example"
