## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(ChestVolume)

## ----warning=FALSE------------------------------------------------------------
library(ChestVolume)
knitr::kable(head(sample_data[, 1:6]), "pipe")

## -----------------------------------------------------------------------------
data(sample_data)
processed_data <- process_marker_data(sample_data, convert_to_cm = TRUE)
head(processed_data)


## -----------------------------------------------------------------------------
# Adjust the marker positions by moving them 1 cm toward the chest center
adjusted_data <- adj_position(processed_data, distance = 1)
head(adjusted_data)

## -----------------------------------------------------------------------------
segments <- list(
  upper_left = c("M01", "M02", "M04", "M05","M07", "M08","M10", "M11")
)
volumes<- calculate_volumes(adjusted_data, segments)
head(volumes)

## ----eval=FALSE, warning=FALSE, include=FALSE---------------------------------
#  plot_chest_3d(adjusted_data, segments, selected_segment = 'upper_left')

## -----------------------------------------------------------------------------
plot_2d_volume(volumes, 'Segment')

## ----message=FALSE, warning=FALSE---------------------------------------------
segments <- read_segment_definitions(system.file("extdata", "segment_def.xlsx", package="ChestVolume"))
head(segments)

