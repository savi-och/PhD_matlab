close all, clear all, clc

% Define the file path
%file_path1 = 'C:\Users\Saverio\OneDrive - Imperial College London\PhD folder\Experimental data\EXP23N27- 4434 melanoma explant resistance measurements (short and long term)\tracing extrusion barrier1 (version 2).xlsx';
file_path2 = 'C:\Users\scharalambous\OneDrive - Imperial College London\PhD folder\Experimental data\EXP24N60-meerGold_0.2RFPs_resistance\N60-mEER_20nmgold_res\iPERF\BS\iR1EBv2-RFPs\iR1EBv2-RFPs\Data.txt';
%file_path3 = 'C:\Users\scharalambous\OneDrive - Imperial College London\PhD folder\Experimental data\EXP23N27- 4434 melanoma explant resistance measurements (short and long term)\Data_BS_M3_all.txt';
%file_path4 = 'C:\Users\Saverio\OneDrive - Imperial College London\PhD folder\Experimental data\EXP23N27- 4434 melanoma explant resistance measurements (short and long term)\elveflow.xlsx';


%data = readmatrix(file_path1);
data2 = readtable(file_path2);
%data3 = readtable(file_path3);
%data4 = readmatrix(file_path4);

% Convert the entire table to a double array
doubleArray = table2array(data2);
%doubleArray1 = table2array(data3);



% Extract x and y data from the imported data
% % x = data(2:809527, 5);  % time recorded on sensirion
% % y = data(2:809527, 12); % flow recorded on sensirion
% % x0 = data4 (2:572957,1);
% % y0 = data4 (2:572957,7); % pressure recorded on elveflow port connected to sensirion
x1 =doubleArray (1:end,1); % time recorded on iPerf BlackSystem
y1 = doubleArray (1:end,2); % flow recorded on iPerf BlackSystem
y01= doubleArray (1:end,3); % pressure recorded on iPerf BlackSystem
% x2 = doubleArray1 (1:end,1); % time recorded on iPerf WhiteSystem
% y2 = doubleArray1 (1:end,2); % flow recorded on iPerf WhiteSystem
% y02= doubleArray1 (1:end,3); % pressure recorded on iPerf WhiteSystem

%hours_x0=x0/3600;
hours_x1=x1/3600;
 %hours_x2=x2/3600;

%%

% Window size for the moving average
window_size1 = 855;  % Adjust this based on your requirements

% Compute the moving average
moving_avg1 = movmean(y, window_size1);

% Create a figure and activate the primary y-axis
figure;
yyaxis left;
plot(x, y, 'r-', 'LineWidth', 0.5);
ylabel('Recorded flow (nL/min)','Color','r');
hold on
% Activate the secondary y-axis and plot the data
yyaxis right;
plot(hours_x0, y0, 'b--', 'LineWidth', 2);
ylabel('Recorded Pressure (mbar)','Color', 'b');

yyaxis left;
plot(x, moving_avg1, 'k-.', 'LineWidth', 2);


% Add a title and labels
title('Flow rate profile - no extrusion barrier-elveflow');
xlabel('Perfusion time (hrs)');

% Set the x-axis limits
hours_x0_min = 0;
hours_x0_max = 15.8;
xlim([hours_x0_min, hours_x0_max]);

% Set the limits for the primary (left) y-axis
y3_flow_min = 0;
y_max = 400;
yyaxis left;
ylim([y3_flow_min, y_max]);

% Set the limits for the secondary (right) y-axis
y2_min = 0;
y2_max = 100;
yyaxis right;
ylim([y2_min, y2_max]);


grid on
%%

% % Window size for the moving average
% window_size2 = 3000;  % Adjust this based on your requirements
% 
% % Compute the moving average
% moving_avg2 = movmean(y1, window_size2);

 moving_avg2 = filters_short(y1,x1,60); 
% Create a figure and activate the primary y-axis
figure;
yyaxis left;
plot(hours_x1, y1, 'b-', 'LineWidth', 0.5);
ylabel('Recorded flow (nL/min)');
hold on
% Activate the secondary y-axis and plot the data
yyaxis right;
plot(hours_x1, y01, 'r--', 'LineWidth', 2);
ylabel('Recorded Pressure (mmHg)');

yyaxis left;
plot(hours_x1, moving_avg2, 'k-.', 'LineWidth', 0.5);

% Add a title and labels
title('Flow rate/pressure profile-N60 2mm mEER iR1 BS EBv2 RFPs');
xlabel('Perfusion time (hrs)');

% Set the x-axis limits
% hours_x1_min = 0;
% hours_x1_max = 15;
% xlim([hours_x1_min, hours_x1_max]);

% % % % Set the limits for the primary (left) y-axis
 y1_min = 0;
 y1_max = 70;
 yyaxis left;
ylim([y1_min, y1_max]);

% % Set the limits for the secondary (right) y-axis
% y01_min = 0;
% y01_max = 50;
% yyaxis right;
% ylim([y01_min, y01_max]);

grid on

%%
% % Window size for the moving average
% window_size3 = 3000;  % Adjust this based on your requirements
% 
% % Compute the moving average
% moving_avg3 = movmean(y2, window_size3);

moving_avg3 = filters_short(y2,x2,360); 
% Create a figure and activate the primary y-axis
figure;
yyaxis left;
plot(hours_x2, y2, 'b-', 'LineWidth', 0.5);
ylabel('Recorded flow (nL/min)');
hold on
% Activate the secondary y-axis and plot the data
yyaxis right;
plot(hours_x2, y02, 'r--', 'LineWidth', 2);
ylabel('Recorded Pressure (mmHg)');

yyaxis left;
plot(hours_x2, moving_avg3, 'k-.', 'LineWidth', 0.5);

% Add a title and labels
title('Flow rate/pressure profile-BS-2mm ON N27');
xlabel('Perfusion time (hrs)');

% Set the x-axis limits
% hours_x2_min = 0;
% hours_x2_max = 15;
% xlim([hours_x2_min, hours_x2_max]);

% % % % Set the limits for the primary (left) y-axis
 y2_min = 0;
 y2_max = 60;
 yyaxis left;
ylim([y2_min, y2_max]);

% % Set the limits for the secondary (right) y-axis
y02_min = 0;
y02_max = 50;
yyaxis right;
ylim([y02_min, y02_max]);


grid on

%% Plot r(t)
% hours_x00=data(143644:809526, 5);
% y00= moving_avg1(143644:809526,:); % pressure of elveflow_sensirion port once 80 mbar applied

%R0 = 60./y00; % 80 mbar =60 mmHg
 R1 = y01(87482:end)./moving_avg2(87482:end);
 % R2 = y02(50400:end)./moving_avg3(50400:end);

 figure
 % plot (hours_x2(50400:end), R2,'b--', 'LineWidth',1);
hold on
 plot (hours_x1(87482:end), R1,'m--', 'LineWidth',1);
 %plot (hours_x00, R0,'m--', 'LineWidth',1);
% Set the x-axis limits
% x_min = 0;
% x_max = 0.05;
% xlim([x_min,x_max]);

% y_min=0;
% y_max= 0.2; 
% ylim([y_min,y_max]);

title('Resistance change over time N60 2mm mEER iR4ON EBV2 20 nmg gold');
xlabel('Perfusion time (hrs)');
ylabel('R (mmHg/nL/min)');
%legend( 'WS-EBv1','BS-NEB','SLG64','Location','eastoutside');

grid on
%% Relative r(t) 

%R0r = R0/R0(1,1);
R1r = R1./R1(1,1);
%R2r = R2./R2(1,1);

 figure
 %plot (hours_x2(50400:end), R2r,'b--', 'LineWidth',1);
hold on
%yyaxis left
 plot (hours_x1(87482:end), R1r,'m--', 'LineWidth',1.5);

% y_min=1;
% y_max=4;
% ylim([y_min,y_max]);
ylabel('Relative resistance (-)')
 % yyaxis right
 % plot (hours_x1(30131:end), moving_avg2(30131:end), 'r--', 'LineWidth',0.1)

%  y_min=0;
% y_max=40;
% ylim([y_min,y_max]);
% ylabel('Flow rate (nL/min)')
 %plot (hours_x00, R0r,'m--', 'LineWidth',1);
% Set the x-axis limits
% x_min = 2;
% x_max = 14;
% xlim([x_min,x_max]);

title('Relative change of Resistance over time for N60 2mm mEER iR4ON EBV2 20 nm gold');
xlabel('Perfusion time (hrs)');
%legend('Relative Resistance','Flow rate','SLG64','Location','best');
legend ('EBv2','Extrusion barrier','Location','best')
grid on