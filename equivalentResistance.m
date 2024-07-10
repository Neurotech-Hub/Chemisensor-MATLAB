function R_v = equivalentResistance(adcValue)
    VREF = 2.5;                   % Reference voltage
    GAIN = 1;                     % Assuming gain of 1 for simplicity
    ADC_RANGE = 2^23 - 1;         % 24-bit ADC range adjusted for unipolar measurement
    currentSource = 10e-6;        % Current source value (10 microamperes)
    fixedResistor = 10000;        % Fixed resistor value (10k ohms)
    gain = 25;                    % Sensor gain
    
    % Calculate the voltage before the gain stage
    bufferVoltage = (adcValue * VREF) / (GAIN * ADC_RANGE);
    % fprintf('Buffer Voltage (before gain adjustment): %.10f\n', bufferVoltage);
    
    % Calculate the voltage after the gain stage
    adcVoltage = bufferVoltage / gain;
    % fprintf('ADC Voltage (after gain adjustment): %.10f\n', adcVoltage);
    
    R_eq = adcVoltage / currentSource;
    % fprintf('Equivalent Resistance (R_eq): %.10f\n', R_eq);
    
    R_v = 1 / ((1 / R_eq) - (1 / fixedResistor));
    % fprintf('Rv: %.10f\n', R_v);
end
