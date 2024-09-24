#' Read Segment Definitions from Excel File
#'
#' Reads an Excel file defining the markers in each segment and creates a list suitable for use with
#' \code{plot_chest_3d} and \code{calculate_segment_volumes} functions.
#'
#' @param filepath A string specifying the path to the Excel file containing segment definitions.
#' @return A named list where each element is a character vector of marker names defining a segment.
#' @details The Excel file should have a specific format:
#' \itemize{
#'   \item Each row represents a segment.
#'   \item The first column contains the segment names.
#'   \item Subsequent columns contain the marker names belonging to each segment.
#' }
#' Missing marker entries can be left blank or filled with \code{NA}.
#' @examples
#' # 'segment_def.xlsx' is the Excel file with segment definitions
#' path <- system.file("extdata", "segment_def.xlsx", package="ChestVolume")
#' segments <- read_segment_definitions(path)
#' head(segments)
#' @import readxl
#' @export
read_segment_definitions <- function(filepath) {

  # Read the Excel file
  segment_data <- readxl::read_excel(filepath, col_names = FALSE)

  # Ensure there is at least one column
  if (ncol(segment_data) < 2) {
    stop("The Excel file must have at least two columns: one for segment names and at least one for marker names.")
  }

  # Initialize the segments list
  segments <- list()

  # Loop over each row to extract segment names and marker names
  for (i in 1:nrow(segment_data)) {
    segment_name <- as.character(segment_data[i, 1])
    marker_names <- as.character(segment_data[i, -1])
    # Remove NA and empty strings
    marker_names <- marker_names[!is.na(marker_names) & marker_names != ""]
    # Add to the segments list
    segments[[segment_name]] <- marker_names
  }

  return(segments)
}
