% Read the table from the CSV file
calTable = readtable('/Volumes/NO NAME/CAL.TXT');
boardTable = readtable('/Volumes/NO NAME/B00.TXT');
% calTable = readtable('CAL.TXT');
% boardTable = readtable('B00.TXT');

% Extract the columns
channels = calTable{:, 1};
measuredADCValues = calTable{:, 2};
measuredRValues = calTable{:, 3} / 1000;  % Convert to kΩ
specValues = boardTable{:, 1};
actualValues = boardTable{:, 2};

% Identify the unique values in the second column (Spec values)
uniqueSpecValues = unique(specValues);

% Find the mean ADC value for the 0Ω condition
zeroOhmRows = specValues == 0;
meanADCZeroOhm = mean(measuredADCValues(zeroOhmRows));

% Create subplots for each unique Spec value
numUniqueValues = length(uniqueSpecValues);
close all;
figure('Position', [0, 0, 1400, 1200]); % Adjusted size for three columns

all_mean_differences = NaN(1, numUniqueValues);

for i = 1:numUniqueValues
    % Get the current Spec value
    currentSpecValue = uniqueSpecValues(i);
    
    % Find the rows corresponding to the current Spec value
    rows = specValues == currentSpecValue;
    
    % Extract the corresponding Actual and Measured values
    currentActualValues = actualValues(rows);
    currentMeasuredValues = measuredRValues(rows);
    currentADCValues = measuredADCValues(rows);
    
    % Apply the calibration offset to the ADC values
    adjustedADCValues = currentADCValues - meanADCZeroOhm;
    
    % Convert the adjusted ADC values to resistances
    adjustedRValues = arrayfun(@(x) equivalentResistance(x) / 1000, adjustedADCValues);
    
    % Calculate the differences between Actual and Measured values
    differences = currentMeasuredValues - currentActualValues;
    
    % Calculate mean and standard deviation of the differences
    meanVal = mean(differences);
    all_mean_differences(i) = meanVal;
    stdVal = std(differences);
    
    % Create subplot for Actual vs Measured
    subplot(numUniqueValues, 3, 3*i-2);
    
    % Plot the Actual values at x = 1
    plot(1, currentActualValues, 'bo');
    hold on;
    
    % Plot the Measured values at x = 2
    plot(2, currentMeasuredValues, 'rx');
    
    % Connect corresponding points with lines
    plot([1, 2], [currentActualValues, currentMeasuredValues], 'k-');
    
    % Set plot title and labels
    title(sprintf('%.1f kΩ (%.2fΩ ± %.2fΩ)', currentSpecValue, meanVal*1000, stdVal*1000));
    xlim([0.5 2.5]);
    xticks([1 2]);
    xticklabels({'Actual (kΩ)', 'Measured (kΩ)'});
    ylabel('Resistance (kΩ)');
    
    % Create subplot for ADC box plot
    subplot(numUniqueValues, 3, 3*i-1);
    boxplot(currentADCValues);
    
    % Set plot title and labels
    title(sprintf('%.1f kΩ ADC (%.2f ± %.2f)', currentSpecValue, mean(currentADCValues), std(currentADCValues)));
    ylabel('ADC Values');
    
    % Create subplot for Adjusted Resistances
    subplot(numUniqueValues, 3, 3*i);
    plot(3, adjustedRValues, 'gx');
    hold on;
    
    % Connect corresponding points with lines for adjusted values
    plot([2, 3], [currentMeasuredValues, adjustedRValues], 'g-');
    
    % Set plot title and labels
    title(sprintf('%.1f kΩ Adjusted', currentSpecValue));
    xlim([1.5 3.5]);
    xticks([2 3]);
    xticklabels({'Measured (kΩ)', 'Adjusted (kΩ)'});
    ylabel('Resistance (kΩ)');
end

fprintf("ADC Offset: %1.2f\n", meanADCZeroOhm);
exportgraphics(gcf,'ResistorCalibration.png');