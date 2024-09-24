#' Adjust Marker Positions Towards Center
#'
#' Adjusts the positions of markers by moving them towards the average center position within each timeframe
#' by a specified distance. This accounts for marker protrusion from the skin surface.
#'
#' @param data A data frame where each row represents a marker at a specific timeframe, with columns 'Timeframe', 'Marker', 'X', 'Y', 'Z'.
#' @param distance Numeric value indicating the distance to adjust towards the center (default is 1 cm).
#'
#' @return A data frame of the same dimensions as `data`, containing the adjusted marker coordinates.
#' @details The function calculates the average center position of all markers within each timeframe and moves each marker towards the center
#' by the specified distance along the line connecting the marker to the center.
#' @examples
#' data("sample_data")
#' processed_data <- process_marker_data(head(sample_data))
#' adjusted_data <- adj_position(processed_data, distance = 1)
#' head(adjusted_data)
#'
#' @import dplyr
#' @export
adj_position <- function(data, distance = 1) {

  # Adjust markers for each timeframe
  adjusted_data <- data %>%
    dplyr::group_by(Timeframe) %>%
    dplyr::do({
      markers_df <- .
      # Calculate the center for this timeframe
      center_coords <- colMeans(markers_df[, c("X", "Y", "Z")], na.rm = TRUE)

      # Function to adjust a single marker
      adjust_marker <- function(marker_coords) {
        direction_vector <- center_coords - marker_coords
        norm <- sqrt(sum(direction_vector ^ 2))
        if (norm == 0) {
          # If marker is at the center, no adjustment needed
          return(marker_coords)
        }
        unit_vector <- direction_vector / norm
        adjusted_coords <- marker_coords + distance * unit_vector
        return(adjusted_coords)
      }

      # Apply the adjustment to all markers
      adjusted_coords <- t(apply(markers_df[, c("X", "Y", "Z")], 1, adjust_marker))

      # Create a new data frame with adjusted coordinates
      markers_df[, c("X", "Y", "Z")] <- adjusted_coords
      markers_df
    }) %>%
    dplyr::ungroup()

  return(adjusted_data)
}
