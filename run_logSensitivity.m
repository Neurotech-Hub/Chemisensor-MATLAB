start_path = '/Volumes/CHEMI/';

% Define the filter for the file types
file_filter = '*.TXT';

% Open the multiselect file dialog
[filenames, filepath] = uigetfile(fullfile(start_path, file_filter), 'Select TXT files', 'MultiSelect', 'on');

% Check if the user selected files
if isequal(filenames, 0)
    disp('User selected Cancel');
    return;
end

% Ensure filenames is a cell array
if ~iscell(filenames)
    filenames = {filenames};
end

% Initialize a container for the data and an array for the order of keys
data = containers.Map();
order_of_keys = [];

% Loop through each selected file
for i = 1:length(filenames)
    % Get the full path of the current file
    full_file_path = fullfile(filepath, filenames{i});
    
    % Read the CSV data
    opts = detectImportOptions(full_file_path, 'TextType', 'string');
    opts = setvartype(opts, 'key', 'string');
    file_data = readtable(full_file_path, opts);
    
    % Loop through each row in the file_data
    for row = 1:height(file_data)
        key = file_data{row, 'key'};
        value = file_data{row, 'value'};
        
        % Store the value in the container
        if isKey(data, key)
            data(key) = [data(key); value];
        else
            data(key) = value;
            order_of_keys = [order_of_keys; key];
        end
    end
end

% Close all existing figures
close all;

% Create a new figure
figure('Position', [100, 100, 1600, 400]);

% Number of unique keys
num_keys = length(order_of_keys);

% Container for labels
labels = cell(num_keys, 1);

% Loop through each key in the order they were encountered
for i = 1:num_keys
    key = order_of_keys(i);
    values = data(key);
    
    % Calculate mean and std deviation
    mean_value = mean(values);
    std_value = std(values);
    
    % Normalize values using z-score
    z_values = (values - mean_value) / std_value;
    
    % Create label
    labels{i} = sprintf('%s (%.3f ± %.3f)', key, mean_value, std_value);
    
    % Plot each key's line plot with mean and std
    hold on;
    xline(i,':','Color',[repmat(0.2,[1,4])]);
    plot(i, mean(z_values), '.', 'MarkerSize', 40, 'Color', 'w');
    plot(i, z_values, '.', 'MarkerSize', 10, 'Color', 'r');
end

% Set x-ticks and labels
ax = gca;
ax.XTick = 1:num_keys;
ax.XTickLabel = labels;
ax.TickLabelInterpreter = "none";
xtickangle(30);
ax.FontSize = 10;
ylabel('Z-Score');
title(sprintf('Z-Score Normalized Values for Each Key (n=%i files)',length(filenames)));
