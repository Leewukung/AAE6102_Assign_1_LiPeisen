% 设置文件夹路径
folder_path = 'D:\GNSS\T1';

% 1. 绘制并保存 SNR 图
figure;
plot(1:32, NaN(1,32), 'ko'); % 所有卫星编号，标记为黑色
hold on;
plot(Acquired.sv, Acquired.SNR, 'bo-');  % 捕获到的卫星，标记为蓝色
title('SNR vs Satellite');
xlabel('Satellite Number (SV)');
ylabel('SNR (dB)');
grid on;
text(Acquired.sv, Acquired.SNR, num2str(Acquired.sv'), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
saveas(gcf, fullfile(folder_path, 'SNR_vs_Satellite.png'));  % 保存为 PNG 格式

% 2. 绘制并保存 Doppler 图
figure;
plot(Acquired.sv, Acquired.Doppler, '-o');
title('Doppler Shift vs Satellite');
xlabel('Satellite Number (SV)');
ylabel('Doppler Shift (Hz)');
grid on;
text(Acquired.sv, Acquired.Doppler, num2str(Acquired.sv'), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
saveas(gcf, fullfile(folder_path, 'Doppler_vs_Satellite.png'));  % 保存为 PNG 格式

% 3. 绘制并保存 代码相位图
figure;
plot(Acquired.sv, Acquired.codedelay, '-o');
title('Code Phase vs Satellite');
xlabel('Satellite Number (SV)');
ylabel('Code Phase (chips)');
grid on;
text(Acquired.sv, Acquired.codedelay, num2str(Acquired.sv'), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
saveas(gcf, fullfile(folder_path, 'Code_Phase_vs_Satellite.png'));  % 保存为 PNG 格式

% 4. 绘制并保存 精细频率图
figure;
plot(Acquired.sv, Acquired.fineFreq, '-o');
title('Fine Frequency vs Satellite');
xlabel('Satellite Number (SV)');
ylabel('Fine Frequency (Hz)');
grid on;
text(Acquired.sv, Acquired.fineFreq, num2str(Acquired.sv'), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
saveas(gcf, fullfile(folder_path, 'Fine_Frequency_vs_Satellite.png'));  % 保存为 PNG 格式