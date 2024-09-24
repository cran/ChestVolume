#' Plot 3D Chest Markers with Highlighted Segment and Convex Hull
#'
#' Generates a 3D plot of chest markers with the selected segment highlighted,
#' including the convex hull mesh of the selected segment.
#'
#' @param data A data frame containing adjusted marker coordinates, with columns 'Timeframe', 'Marker', 'X', 'Y', 'Z'.
#' Coordinates should be in consistent units (e.g., centimeters).
#' @param segments A named list where each element is a character vector of marker names defining a segment.
#' @param selected_segment A character string specifying the name of the segment to highlight.
#' @param timeframe A numeric value indicating the timeframe to plot. If NULL, the first timeframe is used.
#' @param point_size Numeric value specifying the size of the markers in the plot (default is 5).
#' @param highlight_color Color to use for the highlighted segment markers and mesh (default is 'red').
#' @param marker_color Color to use for the non-highlighted markers (default is 'blue').
#' @return A `plotly` object representing the 3D plot.
#' @details The function plots all markers at the specified timeframe, highlighting the markers in the selected segment
#' and overlaying the convex hull mesh of the selected segment. The plot is interactive, allowing for rotation and zooming.
#' @examples
#'# Example input data (replace with your actual data)
#'data(sample_data)
#'df<-process_marker_data(head(sample_data))
#'df_a <- adj_position(df)
#' # Define segments
#' segments <- list(
#'   UL = c("M01", "M02", "M03", "M04")
#' )
#' # Plot the 'UL' segment at timeframe 1
#' plot <- plot_chest_3d(df_a, segments, selected_segment = "UL", timeframe = 1)
#' # Display the plot
#' plot
#' @importFrom plotly plot_ly add_trace layout
#' @import geometry
#' @export
plot_chest_3d <- function(data, segments, selected_segment, timeframe = NULL,
                          point_size = 5, highlight_color = 'red', marker_color = 'blue') {


  # Validate inputs
  if (!selected_segment %in% names(segments)) {
    stop("Selected segment not found in the segments list.")
  }

  # Use the first timeframe if not specified
  if (is.null(timeframe)) {
    timeframe <- min(data$Timeframe, na.rm = TRUE)
  }

  # Filter data for the specified timeframe
  data_time <- data %>% subset(Timeframe == timeframe)

  # Identify markers in the selected segment
  selected_markers <- segments[[selected_segment]]

  # Create a color vector for all markers
  data_time$Color <- marker_color
  data_time$Size <- point_size

  # Highlight the selected segment markers
  data_time$Color[data_time$Marker %in% selected_markers] <- highlight_color
  data_time$Size[data_time$Marker %in% selected_markers] <- point_size * 1.5  # Make highlighted markers larger

  # Create 3D scatter plot
  plot <- plotly::plot_ly(data_time, x = ~X, y = ~Y, z = ~Z, type = 'scatter3d', mode = 'markers',
                  marker = list(size = ~Size, color = ~Color),
                  text = ~paste('Marker:', Marker),
                  hoverinfo = 'text')

  # Compute convex hull for the selected segment markers
  segment_data <- data_time[data_time$Marker %in% selected_markers, ]
  coords <- as.matrix(segment_data[, c("X", "Y", "Z")])

  if (nrow(coords) >= 4) {
    # Compute the convex hull
    hull <- geometry::convhulln(coords, output.options = TRUE)

    # Extract vertices and simplices
    vertices <- coords
    simplices <- hull$hull  # Indices of the vertices forming the convex hull faces

    # Adjust indices for 0-based indexing in plotly
    simplices_zero_based <- simplices - 1

    # Add convex hull mesh to the plot
    plot <- plot %>%
      plotly::add_trace(
        x = vertices[, 1],
        y = vertices[, 2],
        z = vertices[, 3],
        i = simplices_zero_based[, 1],
        j = simplices_zero_based[, 2],
        k = simplices_zero_based[, 3],
        type = 'mesh3d',
        name = paste('Convex Hull -', selected_segment),
        facecolor = highlight_color,
        opacity = 0.5,
        showlegend = FALSE, inherit = F
      )
  } else {
    warning("Not enough points to form a convex hull for the selected segment.")
  }

  # Add layout settings
  plot <- plot %>%
    plotly::layout(
      scene = list(
        xaxis = list(title = 'X'),
        yaxis = list(title = 'Y'),
        zaxis = list(title = 'Z'),
        camera = list(eye = list(x = 1.25, y = 1.25, z = 1.25))
      ),
      title = paste('3D Chest Markers at Timeframe', timeframe, '- Highlighted Segment:', selected_segment)
    )

  return(plot)
}
