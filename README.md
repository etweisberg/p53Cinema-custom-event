# p53Cinema-custom-event
p53Cinema: https://github.com/balvahal/p53CinemaManual

## Overview of Work
![poster](https://user-images.githubusercontent.com/58375851/192012480-cccdbbc2-1a3b-428f-8b50-b260095861a9.jpg)

## Cell Tracker
### Modified files:
- `p53Cinema_object_cellTracker.m`: added custom event time series
- `p53Cinema_gui_cellTracker.m`: added button for custom event to cell fate section linked to callback for tracking custom events. modified save and load annotations to work with custom event time series.

## Image Viewer
### Modified files:
- `p53Cinema_object_imageViewer.m`: added series for recording custom event centroids used to determine where patches are located
- `p53Cinema_gui_imageViewer.m`: added displays of custom event patches as white circles in the image viewer

## Analysis Scripts
### Modified files:
- `CellCinemaQuant_Export.m`: exporting traces and custom data to CSVs by condition for a given dataset
- `analysis.ipynb`: processing and aggregating all CSVs by condition and making plots quantifying division phenomena
