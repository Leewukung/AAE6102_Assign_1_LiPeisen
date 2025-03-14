%Purpose:
%   Main function of the software-defined radio (SDR) receiver platform
%
%--------------------------------------------------------------------------
%                           SoftXXXGPS v1.0
% 
% Copyright (C) X X  
% Written by X X


% 
clear; 
format long g;
addpath geo             %  
addpath acqtckpos       % Acquisition, tracking, and postiong calculation functions


%% Parameter initialization 
[file, signal, acq, track, solu, cmn] = initParameters();

 
%% Acquisition 
if ~exist(['Acquired_',file.fileName,'_',num2str(file.skip),'.mat'])
    Acquired = acquisition_hs(file,signal,acq); %
    save(['Acquired_',file.fileName,'_',num2str(file.skip)],'Acquired');    
else
    load(['Acquired_',file.fileName,'_',num2str(file.skip),'.mat']);
end 
fprintf('Acquisition Completed. \n\n');

% 设置文件夹路径
folder_path = 'D:\GNSS\T1';

% 1. SNR 图
subplot(2, 2, 1); % 2x2 网格中的第一个位置
plot(Acquired.sv, Acquired.SNR, '-o');
title('SNR vs Satellite');
xlabel('Satellite Number (SV)');
ylabel('SNR (dB)');
grid on;
% 在图中显示每个卫星的编号
text(Acquired.sv, Acquired.SNR, num2str(Acquired.sv'), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

% 保存 SNR 图
saveas(gcf, fullfile(folder_path, 'SNR_vs_Satellite.png')); % 保存为 PNG 格式

% 2. Doppler 图
subplot(2, 2, 2); % 2x2 网格中的第二个位置
plot(Acquired.sv, Acquired.Doppler, '-o');
title('Doppler Shift vs Satellite');
xlabel('Satellite Number (SV)');
ylabel('Doppler Shift (Hz)');
grid on;
% 在图中显示每个卫星的编号
text(Acquired.sv, Acquired.Doppler, num2str(Acquired.sv'), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

% 保存 Doppler 图
saveas(gcf, fullfile(folder_path, 'Doppler_vs_Satellite.png')); % 保存为 PNG 格式

% 3. 代码相位图
subplot(2, 2, 3); % 2x2 网格中的第三个位置
plot(Acquired.sv, Acquired.codedelay, '-o');
title('Code Phase vs Satellite');
xlabel('Satellite Number (SV)');
ylabel('Code Phase (chips)');
grid on;
% 在图中显示每个卫星的编号
text(Acquired.sv, Acquired.codedelay, num2str(Acquired.sv'), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

% 保存代码相位图
saveas(gcf, fullfile(folder_path, 'Code_Phase_vs_Satellite.png')); % 保存为 PNG 格式

% 4. 精细频率图
subplot(2, 2, 4); % 2x2 网格中的第四个位置
plot(Acquired.sv, Acquired.fineFreq, '-o');
title('Fine Frequency vs Satellite');
xlabel('Satellite Number (SV)');
ylabel('Fine Frequency (Hz)');
grid on;
% 在图中显示每个卫星的编号
text(Acquired.sv, Acquired.fineFreq, num2str(Acquired.sv'), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

% 保存精细频率图
saveas(gcf, fullfile(folder_path, 'Fine_Frequency_vs_Satellite.png')); % 保存为 PNG 格式

% return

%% Do conventional signal tracking and obtain satellites ephemeris
fprintf('Tracking ... \n\n');
if ~exist(['eph_',file.fileName,'_',num2str(track.msToProcessCT/1000),'.mat'])
    % tracking using conventional DLL and PLL
    if ~exist(['TckResult_Eph',file.fileName,'_',num2str(track.msToProcessCT/1000),'.mat']) %
        [TckResultCT, CN0_Eph] =  trackingCT(file,signal,track,Acquired); 
        TckResult_Eph = TckResultCT;
        save(['TckResult_Eph',file.fileName,'_',num2str(track.msToProcessCT/1000)], 'TckResult_Eph','CN0_Eph');        
    else   
        load(['TckResult_Eph',file.fileName,'_',num2str(track.msToProcessCT/1000),'.mat']);
    end 
    
    % navigaion data decode
    fprintf('Navigation data decoding ... \n\n');
    [eph, ~, sbf] = naviDecode_updated(Acquired, TckResult_Eph);
    save(['eph_',file.fileName,'_',num2str(track.msToProcessCT/1000)], 'eph');
    save(['sbf_',file.fileName,'_',num2str(track.msToProcessCT/1000)], 'sbf');
%     save(['TckRstct_',file.fileName,'_',num2str(track.msToProcessCT/1000)], 'TckResultCT'); % Track results are revised in function naviDecode for 20 ms T_coh
else
    load(['eph_',file.fileName,'_',num2str(track.msToProcessCT/1000),'.mat']);
    load(['sbf_',file.fileName,'_',num2str(track.msToProcessCT/1000),'.mat']);
    load(['TckResult_Eph',file.fileName,'_',num2str(track.msToProcessCT/1000),'.mat']);
end 
 
  
%% Find satellites that can be used to calculate user position
posSV  = findPosSV(file,Acquired,eph);
 
%% Do positiong in conventional or vector tracking mode
cnslxyz = llh2xyz(solu.iniPos); % initial position in ECEF coordinate
 
if cmn.vtEnable == 1    
    fprintf('Positioning (VTL) ... \n\n');
  
    % load data to initilize VT
    load(['nAcquired_',file.fileName,'_',num2str(file.skip),'.mat']); % load acquired satellites that can be used to calculate position  
    Acquired = nAcquired;  
    
    load(['eph_',file.fileName,'_',num2str(track.msToProcessCT/1000),'.mat']); % load eph
    load(['sbf_',file.fileName,'_',num2str(track.msToProcessCT/1000),'.mat']); % 
    
    load(['tckRstCT_1ms_',file.fileName,'.mat']);%,'_Grid'
    load(['navSolCT_1ms_',file.fileName,'.mat']); 
     
    [TckResultVT, navSolutionsVT] = ...
                  trackingVT_POS_updated(file,signal,track,cmn,solu,Acquired,cnslxyz,eph,sbf,TckResult_Eph, TckResultCT_pos,navSolutionsCT);  
else 
    load(['nAcquired_',file.fileName,'_',num2str(file.skip),'.mat']); % load acquired satellites that can be used to calculate position  
    Acquired = nAcquired;
    
    [TckResultCT_pos, navSolutionsCT] = ...
           trackingCT_POS_updated(file,signal,track,cmn,Acquired,TckResult_Eph, cnslxyz,eph,sbf,solu); %trackingCT_POS_multiCorr_1ms
                 
end 

fprintf('Tracking and Positioing Completed.\n\n');
 

