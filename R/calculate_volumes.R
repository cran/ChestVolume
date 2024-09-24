#' Calculate Segment Volumes Over Time
#'
#' Calculates the volumes of specified segments over time using convex hulls.
#'
#' @param data A data frame containing adjusted marker coordinates in centimeters, with columns 'Timeframe', 'Marker', 'X', 'Y', 'Z'.
#' @param segments A list of character vectors, each containing marker names defining a segment.
#'
#' @return A data frame with columns 'Timeframe', 'Segment', 'Volume'.
#' @details Coordinates should be in centimeters to ensure correct volume units (cm³).
#' @examples
#' # Define segments (e.g., quadrants of the chest)
#' segments <- list(
#'   UL = c("M01", "M02", "M03", "M04"),
#'   UR = c("M05", "M06", "M07", "M08")
#' )
#'
#' # Assume 'adjusted_data' is the data frame with adjusted marker positions in cm
#' data('sample_data')
#' processed_data <- process_marker_data(head(sample_data))
#' adjusted_data <- adj_position(processed_data)
#' volumes_df <- calculate_volumes(adjusted_data, segments)
#' head(volumes_df)
#'
#' @import dplyr
#' @import geometry
#' @export
calculate_volumes <- function(data, segments) {

  # Initialize a list to store volume data frames
  volume_list <- list()

  # Loop over each segment
  for (segment_name in names(segments)) {
    segment_markers <- segments[[segment_name]]

    # Filter data for the markers in this segment
    segment_data <- data %>%
      dplyr::filter(Marker %in% segment_markers)

    # Calculate volumes for each timeframe
    segment_volumes <- segment_data %>%
      dplyr::group_by(Timeframe) %>%
      dplyr::do({
        df <- .
        coords <- as.matrix(df[, c("X", "Y", "Z")])

        # Handle cases where convex hull cannot be formed
        if (nrow(coords) >= 4) {
          hull <- geometry::convhulln(coords, options = "FA")
          volume <- hull$vol
        } else {
          volume <- NA
        }

        data.frame(Volume = volume)
      }) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(Segment = segment_name)

    # Append to the list
    volume_list[[segment_name]] <- segment_volumes
  }

  # Combine all volume data frames
  volumes_df <- dplyr::bind_rows(volume_list)

  # Reorder columns
  volumes_df <- volumes_df[, c("Timeframe", "Segment", "Volume")]

  # Arrange data
  volumes_df <- volumes_df %>%
    dplyr::arrange(Timeframe, Segment)

  return(volumes_df)
}
