#' @title Deprecated: Process Marker Data
#'
#' @description This function is deprecated. Please use \code{\link{reformat_marker_data}} instead.
#'
#' @param data A data frame containing marker coordinate data for all time frames.
#' @param convert_to_cm Logical, if TRUE, converts units from mm to cm.
#'
#' @return A data frame of the same format as reformat_marker_data().
#'
#' @examples
#' data("sample_data")
#' # Using the old function will show a warning and call reformat_marker_data()
#' processed_data <- process_marker_data(head(sample_data), convert_to_cm = TRUE)
#' head(processed_data)
#'
#' @export
process_marker_data <- function(data, convert_to_cm = FALSE) {
  .Deprecated("reformat_marker_data")
  reformat_marker_data(data, convert_to_cm = convert_to_cm)
}
