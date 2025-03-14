% Load ephemeris and tracking data
load('eph_Opensky_40.mat');  % Ensure ephemeris data is loaded
load('TckResult_EphOpensky_40.mat');  % Ensure tracking data is loaded

% Check if eph and TckResult_Eph are loaded
if exist('eph', 'var') && exist('TckResult_Eph', 'var')
    disp('Ephemeris and tracking data loaded successfully');
else
    error('Required data not found in the loaded files');
end

% Select one satellite (for example, prn = 32)
prn = 32;

% Extract the ephemeris for the selected satellite
if prn <= length(eph)
    satellite_eph = eph(prn);
else
    error('Selected satellite index is out of range.');
end

% Display the ephemeris data for the selected satellite
disp(satellite_eph);

% Extract corresponding tracking results from TckResult_Eph
if prn <= length(TckResult_Eph)
    satellite_tracking = TckResult_Eph(prn);
else
    error('Selected satellite index is out of range.');
end

% Display the tracking results for the selected satellite
disp(satellite_tracking);

% --- Check and Update updatetime Logic ---
% Initialize updatetime if it's missing
if ~isfield(satellite_eph, 'updatetime')
    satellite_eph.updatetime = [];
end

if ~isfield(satellite_eph, 'updatetime_tow')
    satellite_eph.updatetime_tow = [];
end

% Use TOW to calculate the updatetime (this assumes you have TOW data)
if isfield(satellite_eph, 'TOW') && ~isempty(satellite_eph.TOW)
    % Ensure updatetime and TOW have the same length
    satellite_eph.updatetime = [];  % Reset updatetime
    startms = 1;  % Set the initial value for startms (you can adjust this if needed)
    for idx = 1:length(satellite_eph.TOW)
        % Calculate updatetime (in ms)
        index = idx;  % Example: use the index for calculating updatetime
        satellite_eph.updatetime(idx) = (index + (idx)*300) * 20 + (startms - 1);  % Calculate updatetime based on your provided formula
        
        % Calculate updatetime_tow (in seconds)
        satellite_eph.updatetime_tow(idx) = satellite_eph.TOW(idx) + 6;  % Adding 6 seconds as in the formula
    end
end

% Ensure that updatetime and TOW now have the same length
if length(satellite_eph.updatetime) ~= length(satellite_eph.TOW)
    error('The lengths of updatetime and TOW do not match!');
end

% --- Now plot or process the ephemeris data as needed ---
figure;
subplot(3,1,1);
hold on;
if isfield(satellite_eph, 'updatetime') && ~isempty(satellite_eph.updatetime) && ...
        isfield(satellite_eph, 'TOW') && ~isempty(satellite_eph.TOW)
    plot(satellite_eph.updatetime, satellite_eph.TOW, 'DisplayName', sprintf('SV %d', prn));
end
hold off;
title('Satellite Time of Week (TOW) vs. Updatetime');
xlabel('Updatetime [ms]');
ylabel('TOW [s]');
legend('show');

% --- Save the figure ---
% Construct the save path, including prn in the filename
save_path = sprintf('D:\\GNSS\\OS_T3\\OS_T3_with_updatetime_SV%d.png', prn);

% Save the figure to the specified path
saveas(gcf, save_path);
disp(['Figure saved successfully at ' save_path]);

% --- Print Additional Ephemeris Information ---
disp('Additional Ephemeris Information:');

%%

% Extract the ephemeris for the selected satellite
if prn <= length(eph)
    satellite_eph = eph(prn);
else
    error('Selected satellite index is out of range.');
end

% Display the ephemeris data for the selected satellite
disp(satellite_eph);

% 之前的代码...

% --- Plotting star ephemeris parameters ---
figure;

% Plot Eccentricity vs. TOW
if isfield(satellite_eph, 'TOW') && isfield(satellite_eph, 'ecc')
    len = min(length(satellite_eph.TOW), length(satellite_eph.ecc));
    subplot(3,1,1);
    plot(satellite_eph.TOW(1:len), satellite_eph.ecc(1:len), '-b', 'DisplayName', 'Eccentricity');
    title('Eccentricity (ecc) vs. TOW');
    xlabel('Time of Week (TOW) [s]');
    ylabel('Eccentricity');
    ylim([min(satellite_eph.ecc)-0.01, max(satellite_eph.ecc)+0.01]);  % Adjust Y axis to zoom in on data range
    legend('show');
else
    disp('TOW or ecc data missing for SV %d', prn);
end

% Plot Deltan (Equilibrium Correction) vs. TOW
if isfield(satellite_eph, 'TOW') && isfield(satellite_eph, 'deltan')
    len = min(length(satellite_eph.TOW), length(satellite_eph.deltan));
    subplot(3,1,2);
    plot(satellite_eph.TOW(1:len), satellite_eph.deltan(1:len), '-r', 'DisplayName', 'Deltan');
    title('Deltan (Equilibrium Correction) vs. TOW');
    xlabel('Time of Week (TOW) [s]');
    ylabel('Deltan [rad]');
    ylim([min(satellite_eph.deltan)-0.01, max(satellite_eph.deltan)+0.01]);  % Adjust Y axis
    legend('show');
else
    disp('TOW or deltan data missing for SV %d', prn);
end

% Plot M0 (Mean Anomaly) vs. TOW
if isfield(satellite_eph, 'TOW') && isfield(satellite_eph, 'M0')
    len = min(length(satellite_eph.TOW), length(satellite_eph.M0));
    subplot(3,1,3);
    plot(satellite_eph.TOW(1:len), satellite_eph.M0(1:len), '-g', 'DisplayName', 'M0 (Mean Anomaly)');
    title('M0 (Mean Anomaly) vs. TOW');
    xlabel('Time of Week (TOW) [s]');
    ylabel('M0 [rad]');
    ylim([min(satellite_eph.M0)-0.1, max(satellite_eph.M0)+0.1]);  % Adjust Y axis
    legend('show');
else
    disp('TOW or M0 data missing for SV %d', prn);
end

% Adjust the layout to avoid overlap
tight_layout;

% Save the figure with prn included in the filename
save_path = sprintf('D:\\GNSS\\OS_T3\\OS_T3_Eph_SV%d.png', prn);
saveas(gcf, save_path);
disp(['Figure saved successfully at ' save_path]);



