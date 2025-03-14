Acquired = acquisition_hs(file, signal, acq);

%% Save Acquired data to file
save('D:\GNSS\Acquired_Urban_5000.mat', 'Acquired');
disp(Acquired);  % Print the contents of Acquired to verify

% Plot results
plotAcquisitionResults(Acquired);

function plotAcquisitionResults(Acquired)
    % Plot 1: SNR vs SV
    figure;
    plot(Acquired.sv, Acquired.SNR, '-o', 'LineWidth', 2, 'MarkerSize', 6);
    title('SNR vs Satellite');
    xlabel('Satellite Number (SV)');
    ylabel('SNR (dB)');
    grid on;
    set(gca, 'YScale', 'linear');
    
    % Add text labels for each satellite
    for i = 1:length(Acquired.sv)
        text(Acquired.sv(i), Acquired.SNR(i), num2str(Acquired.sv(i)), ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
    end
    
    saveas(gcf, 'D:\GNSS\UC_T1\SNR_vs_Satellite.png'); % Save the figure

    % Plot 2: Doppler vs SV
    figure;
    plot(Acquired.sv, Acquired.Doppler, '-o', 'LineWidth', 2, 'MarkerSize', 6);
    title('Doppler vs Satellite');
    xlabel('Satellite Number (SV)');
    ylabel('Doppler (Hz)');
    grid on;
    
    % Add text labels for each satellite
    for i = 1:length(Acquired.sv)
        text(Acquired.sv(i), Acquired.Doppler(i), num2str(Acquired.sv(i)), ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
    end
    
    saveas(gcf, 'D:\GNSS\UC_T1\Doppler_vs_Satellite.png'); % Save the figure

    % Plot 3: Code Delay vs SV
    figure;
    plot(Acquired.sv, Acquired.codedelay, '-o', 'LineWidth', 2, 'MarkerSize', 6);
    title('Code Delay vs Satellite');
    xlabel('Satellite Number (SV)');
    ylabel('Code Delay (samples)');
    grid on;
    
    % Add text labels for each satellite
    for i = 1:length(Acquired.sv)
        text(Acquired.sv(i), Acquired.codedelay(i), num2str(Acquired.sv(i)), ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
    end
    
    saveas(gcf, 'D:\GNSS\UC_T1\CodeDelay_vs_Satellite.png'); % Save the figure

    % Plot 4: Fine Frequency vs SV
    figure;
    plot(Acquired.sv, Acquired.fineFreq, '-o', 'LineWidth', 2, 'MarkerSize', 6);
    title('Fine Frequency vs Satellite');
    xlabel('Satellite Number (SV)');
    ylabel('Fine Frequency (Hz)');
    grid on;
    
    % Add text labels for each satellite
    for i = 1:length(Acquired.sv)
        text(Acquired.sv(i), Acquired.fineFreq(i), num2str(Acquired.sv(i)), ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
    end
    
    saveas(gcf, 'D:\GNSS\UC_T1\FineFreq_vs_Satellite.png'); % Save the figure
end