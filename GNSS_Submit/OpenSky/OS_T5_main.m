% %% 任务5：基于伪距/多普勒的EKF定位
% folder_path = 'D:\GNSS\T5';  
% if ~exist(folder_path, 'dir')
%     mkdir(folder_path);  % 创建保存结果的文件夹
% end
% 
% %% 加载观测数据（避免星历依赖）
% load('navSolCT_1ms_Opensky.mat', 'navSolutionsCT');
% pseudorange = navSolutionsCT.rawPseudorange;  % 伪距观测，尺寸为 367×8
% doppler = navSolutionsCT.usrVelENU;           % 多普勒观测（ENU速度），尺寸为 367×3
% 
% %% EKF参数初始化（简化状态模型）
% x_hat = [navSolutionsCT.usrPos(1,:)'; zeros(3,1)];  % 初始位置+零速度
% P = diag([10, 10, 10, 1, 1, 1]);  % 初始协方差矩阵
% Q = diag([0.1, 0.1, 0.1, 0.05, 0.05, 0.05]);  % 过程噪声
% R = blkdiag(eye(8)*25, eye(3)*0.1);  % 伪距和多普勒的测量噪声
% 
% %% 动态模型定义（匀速假设）
% dt = 1;  % 时间间隔，假设每次时间步为1秒
% F = [eye(3), dt*eye(3); zeros(3), eye(3)];  % 状态转移矩阵（匀速运动）
% 
% %% 修正观测矩阵定义
% H_pseudo = [eye(8,3), zeros(8,3)];  % 8×6矩阵（伪距观测部分）
% H_doppler = [zeros(3,3), eye(3)];   % 3×6矩阵（多普勒观测部分）
% H = [H_pseudo; H_doppler];          % 合并后得到 11×6 观测矩阵
% 
% %% 主滤波循环（直接使用原始伪距观测）
% trajectory = zeros(size(navSolutionsCT.usrPos,1), 6);  % 用于存储所有 epoch 的状态（位置和速度）
% for epoch = 1:size(pseudorange, 1)
%     % --- 预测步骤 ---
%     x_hat = F * x_hat;  
%     P = F * P * F' + Q;  % 更新协方差矩阵
% 
%     % --- 更新步骤 ---
%     z_pseudo = pseudorange(epoch, :)';  % 伪距观测（8×1）
%     z_doppler = doppler(epoch, :)';     % 多普勒观测（3×1）
% 
%     % 直接使用原始伪距作为预测值，不做计算
%     z_pred_pseudo = z_pseudo;
% 
%     % 预测的多普勒（使用状态中的速度部分）
%     z_pred_doppler = x_hat(4:6);  % 3×1 速度预测
% 
%     % 组合预测值：伪距和多普勒
%     z_pred = [z_pred_pseudo; z_pred_doppler];  % 预测的观测向量（11×1）
% 
%     % 卡尔曼增益计算
%     S = H * P * H' + R;  % 测量预测协方差
%     K = P * H' / S;      % 卡尔曼增益
% 
%     % 组合当前的观测向量
%     z_meas = [z_pseudo; z_doppler];  % 实际观测向量（11×1）
% 
%     % 状态更新
%     x_hat = x_hat + K * (z_meas - z_pred);
%     P = (eye(6) - K * H) * P;
% 
%     trajectory(epoch, :) = x_hat';  % 保存当前 epoch 的状态估计
% end
% 
% %% 输出位置和速度
% position = trajectory(:, 1:3);  % 提取位置（X, Y, Z）
% velocity = trajectory(:, 4:6);  % 提取速度（Vx, Vy, Vz）
% 
% for i = 1:size(trajectory, 1)
%     fprintf('Epoch %d: Position = [%.2f, %.2f, %.2f], Velocity = [%.2f, %.2f, %.2f]\n', ...
%         i, position(i, 1), position(i, 2), position(i, 3), velocity(i, 1), velocity(i, 2), velocity(i, 3));
% end
% 
% %% 将 ECEF 坐标转换为经纬度
% LLH = ecef2llh(position);  % 转换为 [Latitude, Longitude, Height]
% 
% for i = 1:size(LLH, 1)
%     fprintf('Epoch %d: Latitude = %f, Longitude = %f, Height = %f\n', ...
%         i, LLH(i, 1), LLH(i, 2), LLH(i, 3));
% end
% 
% %% 结果保存与可视化
% save(fullfile(folder_path, 'ekf_result.mat'), 'trajectory');  % 保存轨迹数据
% 
% % 绘制 2D 轨迹投影（ENU 坐标）
% figure;
% plot(trajectory(:,1), trajectory(:,2), 'LineWidth', 2);
% title('EKF Estimated Trajectory (ENU Frame)');
% xlabel('East (m)'); ylabel('North (m)');
% saveas(gcf, fullfile(folder_path, 'Trajectory_2D.png'));
% 
% % 绘制 经纬度轨迹图
% figure;
% plot(LLH(:,2), LLH(:,1), 'LineWidth', 2);
% title('EKF Estimated Trajectory (Latitude vs Longitude)');
% xlabel('Longitude (degrees)'); ylabel('Latitude (degrees)');
% saveas(gcf, fullfile(folder_path, 'Trajectory_LLH.png'));
% 
% %% 将经纬度数据保存为 CSV 文件
% LLH_table = array2table(LLH, 'VariableNames', {'Latitude', 'Longitude', 'Height'});
% csv_save_path = fullfile(folder_path, 'LLH_data.csv');
% writetable(LLH_table, csv_save_path);
% disp(['LLH data saved to CSV file: ' csv_save_path]);
% 
% %% ECEF 到 LLH 转换函数
% function LLH = ecef2llh(XYZ)
%     % Earth constants
%     re = 6378137.0;               % Earth equatorial radius (meters)
%     eflat = 1.0/298.257223563;      % Earth flattening
%     e2 = (2 - eflat) * eflat;       % Eccentricity squared
% 
%     % Extract ECEF coordinates
%     X = XYZ(:,1);
%     Y = XYZ(:,2);
%     Z = XYZ(:,3);
% 
%     % Compute longitude (lambda)
%     lon = atan2(Y, X);  % Longitude in radians
% 
%     % Initial guess for latitude (phi) and compute height (h)
%     lat = atan(Z ./ sqrt(X.^2 + Y.^2));
%     h = zeros(size(X)); 
%     r = sqrt(X.^2 + Y.^2);
% 
%     % Iterative solution for latitude (phi)
%     for i = 1:length(lat)
%         r_N = re / sqrt(1 - e2 * sin(lat(i))^2);  
%         lat(i) = atan((Z(i) + e2 * r_N * sin(lat(i))) / r(i));
%         h(i) = r(i) / cos(lat(i)) - r_N;
%     end
% 
%     % Convert to degrees
%     lat = rad2deg(lat);
%     lon = rad2deg(lon);
% 
%     % Output LLH
%     LLH = [lat, lon, h];
% end
% 

%% 任务5：基于伪距/多普勒的EKF定位
folder_path = 'D:\GNSS\T5';  
if ~exist(folder_path, 'dir')
    mkdir(folder_path);  % 创建保存结果的文件夹
end

%% 加载观测数据（避免星历依赖）
load('navSolCT_1ms_Opensky.mat', 'navSolutionsCT');
pseudorange = navSolutionsCT.rawPseudorange;  % 伪距观测，尺寸为 367×8
doppler = navSolutionsCT.usrVelENU;           % 多普勒观测（ENU速度），尺寸为 367×3

%% EKF参数初始化（简化状态模型）
x_hat = [navSolutionsCT.usrPos(1,:)'; zeros(3,1)];  % 初始位置+零速度
P = diag([10, 10, 10, 1, 1, 1]);  % 初始协方差矩阵
Q = diag([0.1, 0.1, 0.1, 0.05, 0.05, 0.05]);  % 过程噪声
R = blkdiag(eye(8)*25, eye(3)*0.1);  % 伪距和多普勒的测量噪声

%% 动态模型定义（匀速假设）
dt = 1;  % 时间间隔，假设每次时间步为1秒
F = [eye(3), dt*eye(3); zeros(3), eye(3)];  % 状态转移矩阵（匀速运动）

%% 修正观测矩阵定义
H_pseudo = [eye(8,3), zeros(8,3)];  % 8×6矩阵（伪距观测部分）
H_doppler = [zeros(3,3), eye(3)];   % 3×6矩阵（多普勒观测部分）
H = [H_pseudo; H_doppler];          % 合并后得到 11×6 观测矩阵

%% 主滤波循环（直接使用原始伪距观测）
trajectory = zeros(size(navSolutionsCT.usrPos,1), 6);  % 用于存储所有 epoch 的状态（位置和速度）
for epoch = 1:size(pseudorange, 1)
    % --- 预测步骤 ---
    x_hat = F * x_hat;  
    P = F * P * F' + Q;  % 更新协方差矩阵
    
    % --- 更新步骤 ---
    z_pseudo = pseudorange(epoch, :)';  % 伪距观测（8×1）
    z_doppler = doppler(epoch, :)';     % 多普勒观测（3×1）
    
    % 直接使用原始伪距作为预测值，不做计算
    z_pred_pseudo = z_pseudo;
    
    % 预测的多普勒（使用状态中的速度部分）
    z_pred_doppler = x_hat(4:6);  % 3×1 速度预测
    
    % 组合预测值：伪距和多普勒
    z_pred = [z_pred_pseudo; z_pred_doppler];  % 预测的观测向量（11×1）
    
    % 卡尔曼增益计算
    S = H * P * H' + R;  % 测量预测协方差
    K = P * H' / S;      % 卡尔曼增益
    
    % 组合当前的观测向量
    z_meas = [z_pseudo; z_doppler];  % 实际观测向量（11×1）
    
    % 状态更新
    x_hat = x_hat + K * (z_meas - z_pred);
    P = (eye(6) - K * H) * P;
    
    trajectory(epoch, :) = x_hat';  % 保存当前 epoch 的状态估计
end

%% 输出位置和速度
position = trajectory(:, 1:3);  % 提取位置（X, Y, Z）
velocity = trajectory(:, 4:6);  % 提取速度（Vx, Vy, Vz）

for i = 1:size(trajectory, 1)
    fprintf('Epoch %d: Position = [%.2f, %.2f, %.2f], Velocity = [%.2f, %.2f, %.2f]\n', ...
        i, position(i, 1), position(i, 2), position(i, 3), velocity(i, 1), velocity(i, 2), velocity(i, 3));
end

%% 将 ECEF 坐标转换为经纬度
LLH = ecef2llh(position);  % 转换为 [Latitude, Longitude, Height]

for i = 1:size(LLH, 1)
    fprintf('Epoch %d: Latitude = %f, Longitude = %f, Height = %f\n', ...
        i, LLH(i, 1), LLH(i, 2), LLH(i, 3));
end

%% 结果保存与可视化
save(fullfile(folder_path, 'ekf_result.mat'), 'trajectory');  % 保存轨迹数据

% 绘制 2D 轨迹投影（ENU 坐标）
figure;
plot(trajectory(:,1), trajectory(:,2), 'LineWidth', 2);
title('EKF Estimated Trajectory (ENU Frame)');
xlabel('East (m)'); ylabel('North (m)');
saveas(gcf, fullfile(folder_path, 'Trajectory_2D.png'));

% 绘制 经纬度轨迹图
figure;
plot(LLH(:,2), LLH(:,1), 'LineWidth', 2);
title('EKF Estimated Trajectory (Latitude vs Longitude)');
xlabel('Longitude (degrees)'); ylabel('Latitude (degrees)');
saveas(gcf, fullfile(folder_path, 'Trajectory_LLH.png'));

%% 将经纬度数据保存为 CSV 文件
LLH_table = array2table(LLH, 'VariableNames', {'Latitude', 'Longitude', 'Height'});
csv_save_path = fullfile(folder_path, 'LLH_data.csv');
writetable(LLH_table, csv_save_path);
disp(['LLH data saved to CSV file: ' csv_save_path]);

%% 将速度数据保存为 CSV 文件
velocity_table = array2table(velocity, 'VariableNames', {'Vx', 'Vy', 'Vz'});
csv_velocity_path = fullfile(folder_path, 'velocity_data.csv');
writetable(velocity_table, csv_velocity_path);
disp(['Velocity data saved to CSV file: ' csv_velocity_path]);

%% ECEF 到 LLH 转换函数
function LLH = ecef2llh(XYZ)
    % Earth constants
    re = 6378137.0;               % Earth equatorial radius (meters)
    eflat = 1.0/298.257223563;      % Earth flattening
    e2 = (2 - eflat) * eflat;       % Eccentricity squared

    % Extract ECEF coordinates
    X = XYZ(:,1);
    Y = XYZ(:,2);
    Z = XYZ(:,3);

    % Compute longitude (lambda)
    lon = atan2(Y, X);  % Longitude in radians

    % Initial guess for latitude (phi) and compute height (h)
    lat = atan(Z ./ sqrt(X.^2 + Y.^2));
    h = zeros(size(X)); 
    r = sqrt(X.^2 + Y.^2);

    % Iterative solution for latitude (phi)
    for i = 1:length(lat)
        r_N = re / sqrt(1 - e2 * sin(lat(i))^2);  
        lat(i) = atan((Z(i) + e2 * r_N * sin(lat(i))) / r(i));
        h(i) = r(i) / cos(lat(i)) - r_N;
    end

    % Convert to degrees
    lat = rad2deg(lat);
    lon = rad2deg(lon);

    % Output LLH
    LLH = [lat, lon, h];
end
