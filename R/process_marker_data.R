#' Process and Sort Marker Data for All Time Frames
#'
#' Processes the input dataset by sorting marker columns based on marker names
#' and reformats it into a long format with columns 'Timeframe', 'Marker', 'X', 'Y', 'Z'.
#' Adds a Timeframe column corresponding to each row (time frame) in the original data.
#'
#' @param data A data frame containing marker coordinate data for all time frames.
#'        Columns should be named in the format 'MXX X', 'MXX Y', 'MXX Z' where 'MXX' is the marker name.
#' @param convert_to_cm Logical, if TRUE, divides X, Y, Z coordinates by 10 to convert to centimeters (from millimeters).
#' @return A data frame with columns 'Timeframe', 'Marker', 'X', 'Y', 'Z', sorted by Timeframe and Marker.
#' @details The function reshapes the wide-format data into a long format suitable for analysis,
#' adding a Timeframe column that corresponds to each time frame. Optionally converts units to centimeters.
#' @examples
#' data(sample_data)
#' processed_data <- process_marker_data(head(sample_data), convert_to_cm = TRUE)
#' head(processed_data)
#'
#' @import tidyr
#' @export
process_marker_data <- function(data, convert_to_cm = TRUE) {


  # Add Timeframe column
  data$Timeframe <- 1:nrow(data)

  # Gather the data into long format
  long_data <- data %>%
    tidyr::pivot_longer(
      cols = -Timeframe,
      names_to = "Variable",
      values_to = "Value"
    )

  # Separate 'Variable' into 'Marker' and 'Axis'
  long_data <- long_data %>%
    tidyr::separate(Variable, into = c("Marker", "Axis"), sep = " ")

  # Pivot wider to have 'X', 'Y', 'Z' as columns
  processed_data <- long_data %>%
    tidyr::pivot_wider(
      names_from = Axis,
      values_from = Value
    )

  # Convert columns to appropriate types
  processed_data$Timeframe <- as.integer(processed_data$Timeframe)
  processed_data$X <- as.numeric(processed_data$X)
  processed_data$Y <- as.numeric(processed_data$Y)
  processed_data$Z <- as.numeric(processed_data$Z)

  # If convert_to_cm is TRUE, divide X, Y, Z by 10 to convert from mm to cm
  if (convert_to_cm) {
    processed_data$X <- processed_data$X / 10
    processed_data$Y <- processed_data$Y / 10
    processed_data$Z <- processed_data$Z / 10
  }

  # Sort the data by Timeframe and Marker
  processed_data <- processed_data[order(processed_data$Timeframe, processed_data$Marker), ]

  # Reset row names
  rownames(processed_data) <- NULL

  return(processed_data)
}
