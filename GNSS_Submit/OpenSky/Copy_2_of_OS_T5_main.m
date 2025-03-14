%% 任务5：基于伪距/多普勒的EKF定位
folder_path = 'D:\GNSS\T5';  
if ~exist(folder_path, 'dir')
    mkdir(folder_path);  % 路径管理延续任务1-4逻辑
end

%% 加载观测数据（避免星历依赖）
load('navSolCT_1ms_Opensky.mat', 'navSolutionsCT');
pseudorange = navSolutionsCT.rawPseudorange;  % 367×8 伪距观测
doppler = navSolutionsCT.usrVelENU;           % 367×3 多普勒观测（ENU速度）

%% EKF参数初始化（简化状态模型）
% 状态：位置（x, y, z）和速度（vx, vy, vz）
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

%% 合并观测矩阵（列数一致）
H = [H_pseudo; H_doppler];  % 11×6矩阵，合并伪距和多普勒观测

%% 主滤波循环（去卫星位置计算）
trajectory = zeros(size(navSolutionsCT.usrPos,1), 6);  % 存储轨迹（位置和速度）
for epoch = 1:size(pseudorange, 1)
    % --- 预测步骤 ---
    x_hat = F * x_hat;  
    P = F * P * F' + Q;  % 更新协方差矩阵
    
    % --- 更新步骤 ---
    z_pseudo = pseudorange(epoch, :)';  % 伪距观测（8×1）
    z_doppler = doppler(epoch, :)';     % 多普勒观测（3×1）
    
    % 伪距残差计算（基于当前位置与卫星的几何距离）
    z_pred_pseudo = zeros(8, 1);  % 8个卫星的预测伪距
    for i = 1:8
        % 计算用户位置与卫星之间的几何距离
        dx = x_hat(1) - navSolutionsCT.usrPos(i, 1);  % 计算x方向上的差异
        dy = x_hat(2) - navSolutionsCT.usrPos(i, 2);  % 计算y方向上的差异
        dz = x_hat(3) - navSolutionsCT.usrPos(i, 3);  % 计算z方向上的差异
        z_pred_pseudo(i) = sqrt(dx^2 + dy^2 + dz^2);  % 计算几何距离（即伪距）
    end
    
    % 预测的多普勒（使用速度分量）
    z_pred_doppler = x_hat(4:6);  % 速度预测

    % 组合预测值：伪距和多普勒
    z_pred = [z_pred_pseudo; z_pred_doppler];  % 预测的伪距和速度（11×1）
    
    % 卡尔曼增益计算
    S = H * P * H' + R;  % 测量预测协方差
    K = P * H' / S;  % 卡尔曼增益
    
    % 状态更新
    z_meas = [z_pseudo; z_doppler];  % 当前的伪距和多普勒测量（11×1）
    x_hat = x_hat + K * (z_meas - z_pred);  % 更新状态估计
    P = (eye(6) - K * H) * P;  % 更新协方差矩阵
    
    trajectory(epoch, :) = x_hat';  % 保存当前估计的状态
end

%% 输出位置和速度
position = trajectory(:, 1:3);  % 提取位置（X, Y, Z）
velocity = trajectory(:, 4:6);  % 提取速度（Vx, Vy, Vz）

% 输出位置和速度到命令窗口
for i = 1:size(trajectory, 1)
    fprintf('Epoch %d: Position = [%.2f, %.2f, %.2f], Velocity = [%.2f, %.2f, %.2f]\n', ...
            i, position(i, 1), position(i, 2), position(i, 3), velocity(i, 1), velocity(i, 2), velocity(i, 3));
end

%% 结果保存与可视化（延续任务1-4格式）
save(fullfile(folder_path, 'ekf_result.mat'), 'trajectory');  % 存储结果数据
figure;
plot(trajectory(:,1), trajectory(:,2), 'LineWidth', 2);  % 绘制2D轨迹投影
title('EKF Estimated Trajectory (ENU Frame)');
xlabel('East (m)'); ylabel('North (m)');
saveas(gcf, fullfile(folder_path, 'Trajectory_2D.png'));  % 保存图像
