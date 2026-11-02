close all, clear all, clc
% Specify the file path
file_path = 'C:\Users\scharalambous\OneDrive - Imperial College London\PhD folder\Experimental data\EXP24N49 - 4434 melanoma microbead_resistance\P1\White System\2024_06_13 (1)\2024_06_13\N49iNEB_R4ON\Parameters'; %Parameters';

% Use readtable to load the data
data = readtable(file_path);

% Extract x and y data from the imported data
x = data([3:6], 1);  
y = data([3:6], 3);
QON=data(5:end,1);
P0N=data(5:end,3);
time= data(5:end,13);



% convert column into vector
average_flow= table2array(x);
average_pressure = table2array (y);
average_pressure_of=average_pressure*1.33;


%time_hr = time/3600;
% Create a scatter plot
%scatter(data,"Var1","Var3",'filled') % 'b' sets the color to blue, 'filled' fills the markers


%%
% Example standard deviations (replace with your actual standard deviations)
std_x= data([3:6],2);
std_y = data ([3:6],4);
std_deviation_flow=table2array(std_x);
std_deviation_pressure= table2array(std_y);
%% Calculate local resistance and associate standard deviation
R_= average_pressure./average_flow;
std_R_ = R_ .* sqrt((std_deviation_flow ./ average_flow).^2 + (std_deviation_pressure ./ average_pressure).^2);


%% Transpose variables
average_flow1= transpose(average_flow);
average_pressure1 =transpose(average_pressure);
average_pressure_off=transpose(average_pressure_of);
std_deviation_flow1=table2array(std_x);
std_deviation_pressure1= table2array(std_y);
R=transpose(R_);
std_R=transpose(std_R_);
%%

%scatter (x1,y1)
errorbar(average_flow, average_pressure, std_deviation_pressure, std_deviation_pressure, std_deviation_flow, std_deviation_flow, 'o', 'MarkerSize', 4, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'LineWidth', 0.5);
hold on

% Fit a linear polynomial (degree 1) to the data
p = polyfit(average_flow, average_pressure, 1);

% Evaluate the fitted polynomial over a range of x values
yFit = polyval(p, average_flow);

mdl=fitlm(average_flow,average_pressure)

% Plot the fitted line
plot(average_flow, yFit, 'r-', 'LineWidth', 1);
plot(mdl)

x_min = min(average_flow)-10;
x_max = max(average_flow)+10;
xlim([x_min, x_max]);

y_min = 0;
y_max = 45;
ylim([y_min, y_max]);


% Add labels, title, and grid
xlabel('Q (nL/min)');
ylabel('ΔP (mmHg)');
title('N60 2mm mEER iR1 BS EBv2 RFPs ΔP vs Q');
grid on;



% Calculate R-squared value
yFit = polyval(p, average_flow);
yMean = mean(average_pressure);
SSR = sum((yFit - yMean).^2);
SSE = sum((average_pressure - yFit).^2);
R2 = SSR / (SSR + SSE);

% Display R-squared value on the plot
txt = sprintf('R^2 = %.4f', R2);
annotation('textbox', [0.2, 0.6, 0.25, 0.1], 'String', txt, 'FitBoxToText', 'on', 'BackgroundColor', 'white');
txt1 = sprintf(' ΔP= %.4f Q + %.4f', p);
annotation('textbox', [0.2, 0.7, 0.25, 0.1], 'String', txt1, 'FitBoxToText', 'on', 'BackgroundColor', 'white');

hold off

%% Qvs DP
figure
errorbar( average_pressure, average_flow, std_deviation_flow, std_deviation_flow, std_deviation_pressure, std_deviation_pressure,'o', 'MarkerSize', 4, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'LineWidth', 0.5);
hold on

% Fit a linear polynomial (degree 1) to the data
p_1 = polyfit(average_pressure, average_flow, 1);

% Evaluate the fitted polynomial over a range of x values
yFit_1 = polyval(p_1, average_pressure);

mdl_1=fitlm(average_pressure,average_flow)

% Plot the fitted line
plot(average_pressure, yFit_1, 'r-', 'LineWidth', 1);
plot(mdl_1)

x_min = min(average_pressure)-10;
x_max = max(average_pressure)+10;
xlim([x_min, x_max]);
% 
% y_min = 0;
% y_max = 45;
% ylim([y_min, y_max]);


% Add labels, title, and grid
xlabel('ΔP (mmHg) ');
ylabel('Q (nL/min)');
title('N60 2mm mEER iR1 BS EBv2 RFPs Q vs ΔP');
grid on;



% Calculate R-squared value
yMean_1 = mean(average_flow);
SSR = sum((yFit_1 - yMean_1).^2);
SSE = sum((average_flow - yFit_1).^2);
R2_1 = SSR / (SSR + SSE);

% Display R-squared value on the plot
txt = sprintf('R^2 = %.4f', R2_1);
annotation('textbox', [0.2, 0.6, 0.25, 0.1], 'String', txt, 'FitBoxToText', 'on', 'BackgroundColor', 'white');
txt1 = sprintf(' Q= %.4f ΔP + %.4f', p_1);
annotation('textbox', [0.2, 0.7, 0.25, 0.1], 'String', txt1, 'FitBoxToText', 'on', 'BackgroundColor', 'white');

hold off
%% Plot resistance over applied pressure
figure

errorbar(average_pressure, R_, std_R_, std_R_,std_deviation_pressure, std_deviation_pressure, 'o', 'MarkerSize', 4, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'LineWidth', 0.5);

xlabel('ΔP (mmHg)');
ylabel('Local Resistance (mmHg/nL/min)');
title('N60 2mm mEER iiR1 BS EBv2 RFPs R vs ΔP');

x_min = min(average_pressure)-10;
x_max = max(average_pressure)+10;
xlim([x_min, x_max]);
y_min=0;
y_max =max(R_)+1;
ylim([y_min, y_max]);
grid on;

%% Store variables
% Choose a folder interactively
folderPath = uigetdir('C:\', 'Select a folder to save your MAT file');

% Check if the user canceled the folder selection
if folderPath == 0
    disp('Folder selection canceled. Exiting...');
    return;
end
% Specify the file name and extension (e.g., 'myVariables.mat')
fileName = 'DP_F_R_STD_ iPERF WS NB iR4ON 2mm 4434 N49 red beads.mat';

% Create the full file path
fullFilePath = fullfile(folderPath, fileName);

% Save the variables to the MAT file
save(fullFilePath, 'average_flow1','std_deviation_flow1', 'average_pressure1','average_pressure_off','std_deviation_pressure1','R','std_R');

disp(['Variables saved to: ' fullFilePath]);
