library(ChestVolume)

data(sample_data)

# Step 1: Process the marker data and convert from mm to cm
processed_data <- process_marker_data(sample_data, convert_to_cm = TRUE)

# Step 2: Adjust the marker positions by moving them 1 cm toward the chest center
adjusted_data <- adj_position(processed_data, distance = 1)

# Step 3: Define the chest segments (example with one segment)
segments <- list(
  upper_left = c("M01", "M02", "M04", "M05","M07", "M08","M10", "M11")
)

# Step 4: Calculate the chest segment volumes
volumes <- calculate_volumes(adjusted_data, segments)

# Step 5: Visualize the chest expansion in 3D
plot_chest_3d(adjusted_data, segments, selected_segment = 'upper_left')

# Step 6: Plot the chest volume changes over time
plot_2d_volume(volumes, 'Segment')
