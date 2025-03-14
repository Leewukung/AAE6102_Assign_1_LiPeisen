% 假设 navSolutionsCT 已经正确加载，并包含 usrPos 字段
N = length(navSolutionsCT.usrPos);  % 获取时刻的数量

% 提取用户位置数据（每个位置包含 x, y, z）
user_positions = navSolutionsCT.usrPos;

function LLH = ecef2llh(XYZ)
    % Earth constants
    re = 6378137.0;           % Earth equatorial radius in meters
    eflat = (1.0/298.257223563);  % Earth flattening
    e2 = (2 - eflat) * eflat; % Eccentricity squared

    % Extract ECEF coordinates
    X = XYZ(:,1);
    Y = XYZ(:,2);
    Z = XYZ(:,3);

    % Compute longitude (lambda)
    lon = atan2(Y, X);  % Longitude in radians

    % Iteratively compute latitude (phi) and height (h)
    lat = atan(Z ./ sqrt(X.^2 + Y.^2));  % Initial guess for latitude
    h = zeros(size(X));  % Height (meters)
    r = sqrt(X.^2 + Y.^2);  % Distance from Z-axis

    % Iterative solution for latitude (phi)
    for i = 1:length(lat)
        r_N = re / sqrt(1 - e2 * sin(lat(i))^2);  % Radius of curvature in the prime vertical
        lat(i) = atan((Z(i) + e2 * r_N * sin(lat(i))) / r(i));  % Update latitude
        h(i) = r(i) / cos(lat(i)) - r_N;  % Calculate height
    end

    % Convert to degrees
    lat = rad2deg(lat);  % Latitude in degrees
    lon = rad2deg(lon);  % Longitude in degrees

    % Output latitude, longitude, and height
    LLH = [lat, lon, h];
end


% 调用 ecef2llh 函数将 ECEF 坐标转换为经纬度（LLH）
LLH = ecef2llh(user_positions);

% 输出经纬度和高度
disp('Latitude, Longitude, and Height:');
for i = 1:N
    fprintf('Point %d: Latitude = %f, Longitude = %f, Height = %f\n', i, LLH(i, 1), LLH(i, 2), LLH(i, 3));
end

% 绘制经纬度图
figure;

% 绘制经纬度散点图
subplot(1, 2, 1);
scatter(LLH(:, 2), LLH(:, 1), 10, 'b', 'DisplayName', 'User Position (Longitude vs Latitude)');
hold on;
title('User Position in Latitude and Longitude');
xlabel('Longitude (degrees)');
ylabel('Latitude (degrees)');
xlim([22, 23]);
ylim([114, 115]);
legend;
grid on;


% 绘制高度图
subplot(1, 2, 2);
plot(LLH(:, 3), 'b', 'DisplayName', 'Height');
title('User Height');
xlabel('Time Index');
ylabel('Height (m)');
legend;
grid on;

% 调整布局
sgtitle('User Position and Height');

% 设置保存路径和文件名
save_path = sprintf('D:\\GNSS\\OS_T4\\OS_T4_Position_LLH.png');

% 保存图形
saveas(gcf, save_path);

% 打印保存成功的消息
disp(['Figure saved successfully at ' save_path]);

% 调用 ecef2llh 函数将 ECEF 坐标转换为经纬度（LLH）
LLH = ecef2llh(user_positions);

% 创建一个包含纬度、经度和高度的表格
LLH_table = array2table(LLH, 'VariableNames', {'lat', 'lon', 'h'});

% 指定要保存的 CSV 文件名（含后缀）
csv_file_name = 'LLH_data.csv';

% 使用 fullfile 拼接目录和文件名，生成完整的保存路径
csv_save_path = fullfile('D:\GNSS\OS_T4', csv_file_name);

% 将表格保存为 CSV 文件
writetable(LLH_table, csv_save_path);

% 打印保存成功的消息
disp(['经纬度数据已保存到 CSV 文件：' csv_save_path]);


velECEF = navSolutionsCT.usrVel;  % 速度向量 [Vx, Vy, Vz] in ECEF
speedECEF = sqrt(sum(velECEF.^2, 2));  % 标量速度

% 打印速度信息（可选）
for i = 1:length(speedECEF)
    fprintf('Epoch %d: Vx = %.2f, Vy = %.2f, Vz = %.2f, Speed = %.2f m/s\n', ...
        i, velECEF(i,1), velECEF(i,2), velECEF(i,3), speedECEF(i));
end

% 将速度向量保存为 CSV
velocity_table = array2table(velECEF, 'VariableNames', {'Vx','Vy','Vz'});
csv_velocity_path = 'D:\GNSS\OS_T4\velocity_ecef_data.csv';
writetable(velocity_table, csv_velocity_path);
disp(['Velocity data saved to CSV file: ' csv_velocity_path]);

% 将速度标量保存为 CSV
speed_table = array2table(speedECEF, 'VariableNames', {'Speed'});
csv_speed_path = 'D:\GNSS\OS_T4\speed_ecef_data.csv';
writetable(speed_table, csv_speed_path);
disp(['Speed data saved to CSV file: ' csv_speed_path]);
