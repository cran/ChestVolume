#' Adjust Marker Positions Towards Center
#'
#' Adjusts the positions of markers by moving them towards a specified center position within each timeframe
#' by a specified distance. The center (centroid) can be determined by one of two methods:
#'
#' 1. **"average"** (default): The centroid is computed as the mean of all marker coordinates in each timeframe.
#' 2. **"convex hull"**: The centroid is computed using a convex hull-based approach, representing a geometrically derived center.
#'
#' @param data A data frame where each row represents a marker at a specific timeframe, with columns 'Timeframe', 'Marker', 'X', 'Y', 'Z'.
#' @param distance Numeric value indicating the distance to adjust markers towards the center (default is 1 cm).
#' @param centroid A character string specifying the method to compute the centroid. Either `"average"` (default) or `"convex hull"`.
#'
#' @return A data frame of the same dimensions as `data`, containing the adjusted marker coordinates.
#'
#' @details
#' When `centroid = "average"`, the centroid is simply the mean of `X`, `Y`, and `Z` for all markers within each timeframe.
#' When `centroid = "convex hull"`, the centroid is computed using a convex hull-based method to identify a more geometrically relevant center.
#'
#' @examples
#' data("sample_data")
#' reformat_data <- reformat_marker_data(head(sample_data))
#'
#' # Using the average centroid (default)
#' adjusted_data_avg <- adj_position(reformat_data, distance = 1, centroid = "average")
#' head(adjusted_data_avg)
#'
#' # Using the convex hull centroid
#' adjusted_data_ch <- adj_position(reformat_data, distance = 1, centroid = "convex hull")
#'
#' @import dplyr
#' @import geometry
#' @export

adj_position <- function(data, distance = 1, centroid = 'Average') {
  convex_hull_centroid <- function(points) {
    # Ensure there are at least 4 points to form a convex hull
    if (nrow(points) < 4) {
      stop("At least 4 points are required to compute a convex hull in 3D.")
    }

    # Compute the convex hull indices
    hull <- geometry::convhulln(points, options = "FA")

    # Extract the triangular faces of the convex hull
    triangles <- hull$hull

    # Find an internal point (e.g., the mean of all vertices)
    internal_point <- colMeans(points)

    # Initialize total volume and centroid accumulator
    total_volume <- 0
    centroid_accumulator <- c(0, 0, 0)

    # Loop through each triangular face to compute tetrahedron volumes and centroids
    for (i in 1:nrow(triangles)) {
      # Extract vertices of the current triangular face
      v1 <- points[triangles[i, 1], ]
      v2 <- points[triangles[i, 2], ]
      v3 <- points[triangles[i, 3], ]

      # Form a tetrahedron using the internal point and the face
      tetrahedron_vertices <- rbind(internal_point, v1, v2, v3)

      # Construct the 4x4 matrix for the determinant calculation
      matrix_4x4 <- cbind(tetrahedron_vertices, 1)

      # Calculate the signed volume of the tetrahedron
      volume <- det(matrix_4x4) / 6

      # Calculate the centroid of the tetrahedron
      tetrahedron_centroid <- colMeans(tetrahedron_vertices)

      # Accumulate weighted centroid and volume
      centroid_accumulator <- centroid_accumulator + abs(volume) * tetrahedron_centroid
      total_volume <- total_volume + abs(volume)
    }

    # Final centroid is the volume-weighted average
    final_centroid <- centroid_accumulator / total_volume
    return(final_centroid)
  }

  calculate_centroids <- function(data) {
    # Ensure the data contains the required columns
    if (!all(c("Timeframe", "X", "Y", "Z") %in% colnames(data))) {
      stop("The dataframe must contain columns: Timeframe, X, Y, Z")
    }

    centroids <- data %>%
      dplyr::group_by(.data$Timeframe) %>%
      dplyr::summarise(
        # Use .data$X, etc. here
        centroid = list(convex_hull_centroid(cbind(.data$X, .data$Y, .data$Z))),
        .groups = "drop"
      ) %>%
      dplyr::rowwise() %>%
      dplyr::mutate(
        # Here, since we are creating new columns, it's fine to name them X, Y, Z
        # but to refer to the old columns in the same pipeline, you would use .data$...
        X = .data$centroid[[1]],
        Y = .data$centroid[[2]],
        Z = .data$centroid[[3]]
      ) %>%
      dplyr::ungroup() %>%
      dplyr::select(.data$Timeframe, .data$X, .data$Y, .data$Z)

    return(centroids)
  }

  # Validate input data
  if (!all(c("Timeframe", "Marker", "X", "Y", "Z") %in% colnames(data))) {
    stop("data must contain 'Timeframe', 'Marker', 'X', 'Y', and 'Z' columns.")
  }

  # Function to adjust a single marker given a center
  adjust_marker <- function(marker_coords, center_coords, dist) {
    direction_vector <- center_coords - marker_coords
    norm <- sqrt(sum(direction_vector ^ 2))
    if (norm == 0) {
      # If marker is at the center, no adjustment needed
      return(marker_coords)
    }
    unit_vector <- direction_vector / norm
    adjusted_coords <- marker_coords + dist * unit_vector
    return(adjusted_coords)
  }

  # If centroid is convex hull calculate the new centorid with convex hull
  if (centroid == 'convex hull') {

    centroid <- calculate_centroids(data)
    m_data <- left_join(data, centroid, by = 'Timeframe')

    adjusted_data <- m_data %>%
      dplyr::group_by(Timeframe) %>%
      dplyr::do({
        markers_df <- .
        # extract the centorid from the merged dataframe

        center_coords<- colMeans(m_data[,6:8])
        # Apply the adjustment to all markers in this timeframe
        adjusted_coords <- t(apply(markers_df[, c("X.x", "Y.x", "Z.x")], 1, function(mc) {
          adjust_marker(mc, center_coords, distance)
        }))

        markers_df[, c("X.x", "Y.x", "Z.x")] <- adjusted_coords
        markers_df[,1:5]

      }) %>%
      dplyr::ungroup()
  } else {
    # If centroid is NULL, use average center position by timeframe as before
    adjusted_data <- data %>%
      dplyr::group_by(Timeframe) %>%
      dplyr::do({
        markers_df <- .
        # Calculate the center for this timeframe
        center_coords <- colMeans(markers_df[, c("X", "Y", "Z")], na.rm = TRUE)

        # Apply the adjustment to all markers in this timeframe
        adjusted_coords <- t(apply(markers_df[, c("X", "Y", "Z")], 1, function(mc) {
          adjust_marker(mc, center_coords, distance)
        }))

        markers_df[, c("X", "Y", "Z")] <- adjusted_coords
        markers_df
      }) %>%
      dplyr::ungroup()
  }
  colnames(adjusted_data) <- c('Timeframe','Marker','X','Y','Z')
  return(adjusted_data)
}

