% % 加载数据
% loadedData = load('TckResult_EphOpensky_40.mat');  % 根据实际文件名调整
% 
% % 设置保存图像的路径
% folder_path = 'D:/GNSS/OS_T2';  % 你想保存图像的路径
% 
% % 选择卫星编号为 22 进行绘图
% svindex = 22;  % 设置卫星编号为 22
% 
% % 提取相关数据
% P_i = loadedData.TckResult_Eph(svindex).P_i; % In-phase prompt correlation values
% P_q = loadedData.TckResult_Eph(svindex).P_q; % Quadrature-phase prompt correlation values
% E_i = loadedData.TckResult_Eph(svindex).E_i; % In-phase early correlation values
% E_q = loadedData.TckResult_Eph(svindex).E_q; % Quadrature-phase early correlation values
% L_i = loadedData.TckResult_Eph(svindex).L_i; % In-phase late correlation values
% L_q = loadedData.TckResult_Eph(svindex).L_q; % Quadrature-phase late correlation values
% 
% % 假设时间延迟范围为 -0.5 到 0.5，生成与相关数据长度匹配的时间延迟向量
% time_delay = linspace(-0.5, 0.5, length(E_i));  % 生成与 E_i 长度匹配的时间延迟向量
% 
% % 选择一个较小的时间段，例如前200个数据点
% subset_size = 50;  % 选择前200个数据点
% time_delay_subset = time_delay(1:subset_size);  % 截取时间延迟
% E_i_subset = E_i(1:subset_size);  % 截取早期相关函数（In-phase）
% P_i_subset = P_i(1:subset_size);  % 截取提示相关函数（In-phase）
% L_i_subset = L_i(1:subset_size);  % 截取后期相关函数（In-phase）
% E_q_subset = E_q(1:subset_size);  % 截取早期相关函数（Quadrature-phase）
% P_q_subset = P_q(1:subset_size);  % 截取提示相关函数（Quadrature-phase）
% L_q_subset = L_q(1:subset_size);  % 截取后期相关函数（Quadrature-phase）
% 
% % 创建图形窗口
% figure;
% 
% % 绘制多条曲线，显示不同时间延迟下的相关函数
% hold on;
% 
% % 绘制不同时间延迟下的相关函数（只绘制选定片段）
% plot(time_delay_subset, E_i_subset, 'b', 'LineWidth', 1.5); % In-phase early
% plot(time_delay_subset, P_i_subset, 'r', 'LineWidth', 1.5); % In-phase prompt
% plot(time_delay_subset, L_i_subset, 'g', 'LineWidth', 1.5); % In-phase late
% plot(time_delay_subset, E_q_subset, 'b--', 'LineWidth', 1.5); % Quadrature-phase early
% plot(time_delay_subset, P_q_subset, 'r--', 'LineWidth', 1.5); % Quadrature-phase prompt
% plot(time_delay_subset, L_q_subset, 'g--', 'LineWidth', 1.5); % Quadrature-phase late
% 
% % 设置标题和坐标轴标签
% title(['Correlation Functions for Satellite ', num2str(svindex)]);
% xlabel('Time Delay (Chip)');
% ylabel('Correlation Value');
% 
% % 添加图例
% legend('Early In-phase', 'Prompt In-phase', 'Late In-phase', ...
%        'Early Quadrature-phase', 'Prompt Quadrature-phase', 'Late Quadrature-phase', 'Location', 'Best');
% 
% grid on;
% hold off;
% 
% % 保存图像
% saveas(gcf, fullfile('D:/GNSS/OS_T2', ['Correlation_Functions_SV_' num2str(svindex) '.png']));


% % 加载数据
% loadedData = load('TckResult_EphOpensky_40.mat');  % 根据实际文件名调整
% 
% % 选择卫星编号为 22 进行绘图
% svindex = 22;  % 设置卫星编号为 22
% 
% % 提取相关数据
% P_i = loadedData.TckResult_Eph(svindex).P_i; % In-phase prompt correlation values
% P_q = loadedData.TckResult_Eph(svindex).P_q; % Quadrature-phase prompt correlation values
% E_i = loadedData.TckResult_Eph(svindex).E_i; % In-phase early correlation values
% E_q = loadedData.TckResult_Eph(svindex).E_q; % Quadrature-phase early correlation values
% L_i = loadedData.TckResult_Eph(svindex).L_i; % In-phase late correlation values
% L_q = loadedData.TckResult_Eph(svindex).L_q; % Quadrature-phase late correlation values
% 
% % 假设时间延迟范围为 -0.5 到 0.5，生成与相关数据长度匹配的时间延迟向量
% time_delay = linspace(-0.5, 0.5, length(E_i));  % 生成与 E_i 长度匹配的时间延迟向量
% 
% % 选择一个较小的时间段，例如前200个数据点
% subset_size = 40000;  % 选择前200个数据点
% time_delay_subset = time_delay(1:subset_size);  % 截取时间延迟
% E_i_subset = E_i(1:subset_size);  % 截取早期相关函数（In-phase）
% P_i_subset = P_i(1:subset_size);  % 截取提示相关函数（In-phase）
% L_i_subset = L_i(1:subset_size);  % 截取后期相关函数（In-phase）
% E_q_subset = E_q(1:subset_size);  % 截取早期相关函数（Quadrature-phase）
% P_q_subset = P_q(1:subset_size);  % 截取提示相关函数（Quadrature-phase）
% L_q_subset = L_q(1:subset_size);  % 截取后期相关函数（Quadrature-phase）
% 
% % 创建图形窗口
% figure;
% 
% % 绘制多条曲线，显示不同时间延迟下的相关函数
% hold on;
% 
% % 绘制不同时间延迟下的相关函数（只绘制选定片段）
% plot(time_delay_subset, E_i_subset, 'b', 'LineWidth', 1.5); % In-phase early
% plot(time_delay_subset, P_i_subset, 'r', 'LineWidth', 1.5); % In-phase prompt
% plot(time_delay_subset, L_i_subset, 'g', 'LineWidth', 1.5); % In-phase late
% plot(time_delay_subset, E_q_subset, 'b--', 'LineWidth', 1.5); % Quadrature-phase early
% plot(time_delay_subset, P_q_subset, 'r--', 'LineWidth', 1.5); % Quadrature-phase prompt
% plot(time_delay_subset, L_q_subset, 'g--', 'LineWidth', 1.5); % Quadrature-phase late
% 
% % 设置标题和坐标轴标签
% title(['Correlation Functions for Satellite ', num2str(svindex)]);
% xlabel('Time Delay (Chip)');
% ylabel('Correlation Value');
% 
% % 设置横坐标范围为对称的 -0.5 到 0.5
% xlim([-0.5 0.5]);  % 强制设置 x 轴范围为对称
% 
% % 添加图例
% legend('Early In-phase', 'Prompt In-phase', 'Late In-phase', ...
%        'Early Quadrature-phase', 'Prompt Quadrature-phase', 'Late Quadrature-phase', 'Location', 'Best');
% 
% grid on;
% hold off;
% 
% % 保存图像
% saveas(gcf, fullfile('D:/GNSS/OS_T2', ['Correlation_Functions_SV_' num2str(svindex) '.png']));


% 加载数据
loadedData = load('TckResult_EphOpensky_40.mat');  % 根据实际文件名调整

% 设置要绘制的卫星编号
svindices = [22, 32];  % 选择卫星编号为 22 和 32

% 设置保存图像的路径
folder_path = 'D:/GNSS/OS_T2';  % 你想保存图像的路径
if ~exist(folder_path, 'dir')
    mkdir(folder_path);  % 创建文件夹（如果不存在）
end

% 逐个处理每个卫星
for svindex = svindices
    % 提取相关数据
    P_i = loadedData.TckResult_Eph(svindex).P_i; % In-phase prompt correlation values
    P_q = loadedData.TckResult_Eph(svindex).P_q; % Quadrature-phase prompt correlation values
    E_i = loadedData.TckResult_Eph(svindex).E_i; % In-phase early correlation values
    E_q = loadedData.TckResult_Eph(svindex).E_q; % Quadrature-phase early correlation values
    L_i = loadedData.TckResult_Eph(svindex).L_i; % In-phase late correlation values
    L_q = loadedData.TckResult_Eph(svindex).L_q; % Quadrature-phase late correlation values

    % 假设时间延迟范围为 -0.5 到 0.5，生成与相关数据长度匹配的时间延迟向量
    time_delay = linspace(-0.5, 0.5, length(E_i));  % 生成与 E_i 长度匹配的时间延迟向量

    % 选择每隔2000个数据点来绘制
    interval = 2000;  % 间隔选择2000个数据点
    indices = 1:interval:length(E_i);  % 每隔2000个点进行选择

    % 提取间隔后的数据
    time_delay_subset = time_delay(indices);  % 截取时间延迟
    E_i_subset = E_i(indices);  % 截取早期相关函数（In-phase）
    P_i_subset = P_i(indices);  % 截取提示相关函数（In-phase）
    L_i_subset = L_i(indices);  % 截取后期相关函数（In-phase）
    E_q_subset = E_q(indices);  % 截取早期相关函数（Quadrature-phase）
    P_q_subset = P_q(indices);  % 截取提示相关函数（Quadrature-phase）
    L_q_subset = L_q(indices);  % 截取后期相关函数（Quadrature-phase）

    % 创建图形窗口
    figure;

    % 绘制多条曲线，显示不同时间延迟下的相关函数
    hold on;

    % 使用不同颜色绘制曲线
    colors = lines(6);  % MATLAB 颜色序列

    plot(time_delay_subset, E_i_subset, 'Color', colors(1,:), 'LineWidth', 1.5); % In-phase early
    plot(time_delay_subset, P_i_subset, 'Color', colors(2,:), 'LineWidth', 1.5); % In-phase prompt
    plot(time_delay_subset, L_i_subset, 'Color', colors(3,:), 'LineWidth', 1.5); % In-phase late
    plot(time_delay_subset, E_q_subset, 'Color', colors(4,:), 'LineStyle', '--', 'LineWidth', 1.5); % Quadrature-phase early
    plot(time_delay_subset, P_q_subset, 'Color', colors(5,:), 'LineStyle', '--', 'LineWidth', 1.5); % Quadrature-phase prompt
    plot(time_delay_subset, L_q_subset, 'Color', colors(6,:), 'LineStyle', '--', 'LineWidth', 1.5); % Quadrature-phase late

    % 设置标题和坐标轴标签
    title(['Correlation Functions for Satellite ', num2str(svindex)]);
    xlabel('Time Delay (Chip)');
    ylabel('Correlation Value');

    % 设置横坐标范围为对称的 -0.5 到 0.5
    xlim([-0.5 0.5]);  % 强制设置 x 轴范围为对称

    % 添加图例
    legend('Early In-phase', 'Prompt In-phase', 'Late In-phase', ...
           'Early Quadrature-phase', 'Prompt Quadrature-phase', 'Late Quadrature-phase', 'Location', 'Best');

    grid on;
    hold off;

    % 保存图像
    saveas(gcf, fullfile(folder_path, ['Correlation_Functions_SV_' num2str(svindex) '.png']));
end




