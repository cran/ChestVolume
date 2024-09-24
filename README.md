# ChestVolume: An R Package for Analyzing Chest Expansion Using 3D Coordinate Data

## Overview

**ChestVolume** is an R package designed for analyzing chest expansion using 3D marker coordinate data collected from motion capture systems. The package allows users to process marker data, adjust marker positions, calculate convex hull volumes of chest segments, and visualize chest movements in both 2D and 3D.

This tool is particularly useful for respiratory health research, enabling detailed assessments of chest expansion and identifying potential asymmetries in breathing patterns.

## Key Features

- **Process 3D Marker Data**: Automatically reshapes wide-format marker data into long format, making it easier to analyze.
- **Adjust Marker Positions**: Corrects the position of motion capture markers by moving them toward the chest surface.
- **Calculate Chest Volumes**: Uses convex hull geometry to calculate chest segment volumes over time.
- **2D and 3D Visualization**: Visualize chest expansion in 2D plots or interact with the chest model in 3D.
- **Shiny App**: A graphical interface to allow non-programmers to interact with the data and analyses.

## Installation

To install **ChestVolume** from GitHub, use the following commands:

```r
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}
devtools::install_github("PKwong86/ChestVolume")
```

## Getting Started
Here is a quick example demonstrating how to use ChestVolume to process 3D marker data, adjust marker positions, and calculate chest segment volumes.
```r
# Load the package
library(ChestVolume)

# Example sample input data 
data(sample_data)

# Step 1: Process the marker data and convert from mm to cm
processed_data <- process_marker_data(sample_data, convert_to_cm = TRUE)

# Step 2: Adjust the marker positions by moving them 1 cm toward the chest center
adjusted_data <- adj_position(processed_data, distance = 1)

# Step 3: Define the chest segments (example with one segment)
segments <- list(
  left = c("M01", "M02", "M03", "M04","M05", "M06","M07", "M08",
  "M09", "M10", "M11","M12", "M13","M14", "M15","M16", "M17","M18")
)

# Step 4: Calculate the chest segment volumes
volumes<- calculate_volumes(adjusted_data, segments)
head(volumes)

# Step 5: Visualize the chest expansion in 3D
plot_chest_3d(adjusted_data, segments, selected_segment = 'left')

# Step 6: Plot the chest volume changes over time
plot_2d_volume(volumes, 'Segment')


```
## Shiny App
For users who prefer a graphical interface, the ChestVolume Shiny app allows you to interact with the data without programming knowledge.

Access the Shiny app online: https://waihangkwong.shinyapps.io/Lung_volumn/
Source Code: The source code for the Shiny app is available at https://github.com/PKwong86/Chestvolume_shiny

## License
This package is released under the MIT License. Feel free to use, modify, and distribute it.
