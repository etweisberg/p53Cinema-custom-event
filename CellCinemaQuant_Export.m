%CHANGE THESE
condition = 'DATASET'; %e.g. FUCCI_SC3
group = '1'; %e.g. 1, 5, 8
path = 'DATASET_PATH'; %e.g. ~/FUCCI_SC3_DATA/


%load the tracking info
database = readDatabaseFile(strcat(condition,'_db.txt'));
measurements = getDatasetTraces_localSegmentation_cytoMean4px(database, condition, strcat('Tracking_',condition,'/',group), '',{'FITC-DISK', 'TRITC-DISK', 'CY5-DISK'}, 'CY5-DISK');


%extract the channel specific info for all cells over time
green = measurements.singleCellTracks_mean{1};
red = measurements.singleCellTracks_mean{2};
nuclear = measurements.singleCellTracks_mean{3};
nucArea = measurements.singleCellTracks_area;
divMatrix = measurements.divisionMatrixDataset;
deathMatrix = measurements.deathMatrixDataset;
customMatrix = measurements.customMatrixDataset;
centroidCol = measurements.centroid_col;
centroidRow = measurements.centroid_row;


%export to CSV for import in Python
writematrix(deathMatrix, strcat(path, group,'_deathMatrix.csv'));
writematrix(divMatrix, strcat(path, group,'_divMatrix.csv'));
writematrix(customMatrix, strcat(path, group,'_customMatrix.csv'));
writematrix(green, strcat(path, group,'_green.csv'));
writematrix(red, strcat(path, group,'_red.csv'));
writematrix(nuclear, strcat(path, group,'_nuclear.csv'))
writematrix(centroidCol, strcat(path, group,'_centroidCol.csv'));
writematrix(centroidRow, strcat(path, group,'_centroidRow.csv'));