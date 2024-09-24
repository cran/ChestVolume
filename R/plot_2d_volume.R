#' Plot Volume Changes by Segment Over Time
#'
#' This function generates a ggplot to display the volume changes by segment over time.
#' It creates a line plot with each segment's volume on the y-axis and the timeframe on the x-axis.
#'
#' @param volume_data A data frame with volume measurements, one column per segment, and a "frame" column for time.
#' @param segment_names Column that contain name of segment to plot
#' @param title Optional plot title.
#' @return A ggplot object showing volume changes by segment over time.
#' @import ggplot2
#' @import tidyr
#' @export
#' @examples
#' # Example usage with random volume data
#' set.seed(123)
#' volume_data <- data.frame(
#'   Timeframe = 1:100,
#'   Volume = runif(100, min = 100, max = 150),
#'   Segment = 'UL'
#' )
#'
#' plot_2d_volume(volume_data, segment_names = 'Segment')
#'
plot_2d_volume <- function(volume_data, segment_names = 'Segment', title = "Volume Change by Segment") {

  # Ensure 'frame' column is present
  if (!"Timeframe" %in% names(volume_data)) {
    stop("The 'volume_data' must contain a 'Timeframe' column for time points.")
  }


  # Create the ggplot
  ggplot2::ggplot(volume_data, aes(x = Timeframe, y = Volume, color = Segment)) +
    ggplot2::geom_line(linewidth = 1) +
    ggplot2::labs(x = "Timeframe", y = "Volume") +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10)
    )
}
