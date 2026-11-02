%%  Define file path and convert CSV to XLSX for flow files
clc,clear, close all
% Specify the path to the CSV file - flow
csvFilePath1 = 'C:\Users\scharalambous\OneDrive - Imperial College London\PhD folder\Experimental data\EXP25N105\R2_WS_y_cells_4434.csv';
% csvFilePath2 = 'C:\Users\scharalambous\OneDrive - Imperial College London\PhD folder\Experimental data\EXP25N75_4434_2.5mm_QPerf_adh_hoechst_ubeads\N75_4434_2.5mm_Hoechst_gr-ubeads_adhesion_37C\Q measurements\Q when system in P eq\S_blue\R1.csv';
% csvFilePath3 = 'C:\Users\scharalambous\OneDrive - Imperial College London\PhD folder\Experimental data\EXP25N75_4434_2.5mm_QPerf_adh_hoechst_ubeads\N75_4434_2.5mm_Hoechst_gr-ubeads_adhesion_37C\Q measurements\Q when system in P eq\WS_yellow\R1.csv';

% Define options for reading the table
opts = detectImportOptions(csvFilePath1);
opts = setvartype(opts, 'string');  % Treat all variables as strings initially


% Read the CSV file into a table
dataTable1 = readtable(csvFilePath1, opts);
% dataTable2 = readtable(csvFilePath2,opts);
% dataTable3 = readtable(csvFilePath3,opts);


opts.VariableNamesLine = 15;  % Specify the row where column names are located
opts.DataLines = 16;          % Specify the row where the data starts

% Display the actual column names (for debugging purposes)
disp('Column Names in dataTable1:');
disp(dataTable1.Properties.VariableNames);

%Convert relevant columns to numeric format (remove commas)
numericColumns = {'Sample_', 'RelativeTime_s_', 'Flow_nl_min_'}; % Specify the column names
%numericColumns = {'Var1', 'Var2', 'Var3'}; % Specify the column names
for col = numericColumns
    dataTable1.(col{:}) = str2double(strrep(dataTable1.(col{:}), ',', ''));
    % dataTable2.(col{:}) = str2double(strrep(dataTable2.(col{:}), ',', ''));
    % dataTable3.(col{:}) = str2double(strrep(dataTable3.(col{:}), ',', ''));

end


% Specify the path for the XLSX file
xlsxFilePath1 = 'C:\Users\scharalambous\OneDrive - Imperial College London\PhD folder\Experimental data\EXP25N105\R2_WS_y_cells_4434.xlsx';
% xlsxFilePath2 = 'C:\Users\scharalambous\OneDrive - Imperial College London\PhD folder\Experimental data\EXP25N75_4434_2.5mm_QPerf_adh_hoechst_ubeads\N75_4434_2.5mm_Hoechst_gr-ubeads_adhesion_37C\Q measurements\Q when system in P eq\S_blue\R1.xlsx';
% xlsxFilePath3 = 'C:\Users\scharalambous\OneDrive - Imperial College London\PhD folder\Experimental data\EXP25N75_4434_2.5mm_QPerf_adh_hoechst_ubeads\N75_4434_2.5mm_Hoechst_gr-ubeads_adhesion_37C\Q measurements\Q when system in P eq\WS_yellow\R1.xlsx';

% Write the table to the XLSX file
writetable(dataTable1, xlsxFilePath1);
% writetable(dataTable2, xlsxFilePath2);
% writetable(dataTable3, xlsxFilePath3);

disp('Conversion completed successfully for flow data.');

% % Specify the path to the TXT file - Pressure
%txtFilePath = 'C:\Users\scharalambous\OneDrive - Imperial College London\PhD folder\Experimental data\EXP25N75_4434_2.5mm_QPerf_adh_hoechst_ubeads\N75_4434_2.5mm_Hoechst_gr-ubeads_adhesion_37C\Explant Resistance\R2\EF_BS2_S3_WS4_R2ON.txt';

% Read the TXT file into a table (assuming it is tab-delimited)
%dataTablep = readtable(txtFilePath, 'Delimiter', '\t');

% Specify the path for the XLSX file
%xlsxFilePathp = 'C:\Users\scharalambous\OneDrive - Imperial College London\PhD folder\Experimental data\EXP25N75_4434_2.5mm_QPerf_adh_hoechst_ubeads\N75_4434_2.5mm_Hoechst_gr-ubeads_adhesion_37C\Explant Resistance\R2\EF_BS2_S3_WS4_R2ON.xlsx';

% Write the table to the XLSX file
%writetable(dataTablep, xlsxFilePathp);

%disp('Conversion completed successfully for pressure data.');
%%
file_path1 = xlsxFilePath1; %'C:\Users\sc5622\OneDrive - Imperial College London\PhD folder\Experimental data\EXP24N43 - Pressure dependence of resistance changes with EB\Q sensor Res\S_blue\R3.xlsx';
% file_path2 = xlsxFilePathp; %'C:\Users\sc5622\OneDrive - Imperial College London\PhD folder\Experimental data\EXP24N43 - Pressure dependence of resistance changes with EB\Q sensor Res\EF_BS2_S3_R3.xlsx';
% file_path3 = xlsxFilePath2 ; %'C:\Users\sc5622\OneDrive - Imperial College London\PhD folder\Experimental data\EXP24N42 microbead infusion with resistance measurements\N42 - microbead and resistance measurement\Q measurements\P offset adjustment\S_blue\R1.xlsx';
% file_path4 = xlsxFilePath3 ;

% Import data from Excel
data = readmatrix(file_path1); % flow data
% data2 = readmatrix(file_path2); % pressure data
% data3 = readmatrix(file_path3);
% data4 = readmatrix(file_path4);
 

% Extract x and y data from the imported data
% t = data2(2:end,2); %time elveflow 
% p = data2(2:end,10); %..,6 for BS orange/ ...,8 for S blue/ ...,10 for WS yellow

t1 = data (2:end,2); % time sensurion
f = data (2:end,3); %sensurion flowsensor BS

% t3 = data3(2:end,2);
% f3= data3(2:end,3); 
% t4 = data4(2:end,2);
% f4= data4(2:end,3); 

% Convert t in hours
% hours_t = t/3600; %time recording pressure
hours_t1=t1/3600; %time recording flow rate
% hours_t3=t3/3600;
% hours_t4=t4/3600;

mins_t1=t1/60;

% hours_t1_255=hours_t1(120496:end);

%% plotting constant error bars
% Specify the number of intervals (n) within the x range 
% nIntervals = 50;
% 
% % Create a vector of zeros for error values
% errorValues = zeros(size(x));
% errorValues1 = zeros(size(x2));
% % Assign error values for specific intervals
% errorIntervals = round(linspace(1, numel(x), nIntervals));
% errorIntervals1 = round(linspace(1, numel(x2), nIntervals));
% errorValues(errorIntervals) = 0.02; % Set the desired error magnitude
% errorValues1(errorIntervals1) = 0.025;
% 

%% Generate filtered flow rates
Qf = filters_short(f,t1,120); % filtered data flow sensurion _S
% Qf3 = filters_short(f3,t3,60);% filtered data flow sensor 2on4
% Qf4 = filters_short(f4,t4,60); % filtered data sensurion

%% Calculate differential dQ/dt, dp/dt and fabs
% Calculate the differential (approximate derivative)
df_dt = abs(diff(f) ./ diff(t1));

Qdf_dt = filters_short (df_dt,t1(1:end-1),14);

dp_dt = abs(diff(p)./diff(t));

f_abs=abs(f);
%% Create a figure and activate the primary y-axis
figure;
yyaxis left;
plot(hours_t1, f, 'b-','LineWidth',2); % 'b-', orange colour 'Color',[0.8500 0.3250 0.0980], 'LineStyle','-', 'LineWidth'
ylabel('Recorded flow rate (nL/min)');

hold on

% plot(hours_t3,f3,'Color','b', 'LineStyle','-', 'LineWidth', 2);
% plot(hours_t4,f4, 'Color', [0.9290 0.6940 0.1250],'LineStyle','-', 'LineWidth', 2);

% hourst11=hours_t1(1:122733);
% hourst12=hours_t1(122733:374829);

p_fluidic=80*ones(size(hours_t1(1:445022)));
p_fluidic1=100*ones(size(hours_t1(445023:452772)));
pfluidic2=120*ones(size(hours_t1(452773:498979)));
pfluidic3=150*ones(size(hours_t1(498980:end)));
%Activate the secondary y-axis and plot the data
yyaxis right;
% plot(hours_t, p, 'r--', 'LineWidth', 2);
ylabel('Applied pressure (mbar)'); %(mbar)
plot(hours_t1(1:445022), p_fluidic, 'r--', 'LineWidth', 2);
plot(hours_t1(445023:452772), p_fluidic1, 'r--', 'LineWidth', 2);
plot(hours_t1(452773:498979), pfluidic2, 'r--', 'LineWidth', 2);
plot(hours_t1(498980:end), pfluidic3, 'r--', 'LineWidth', 2);

 yyaxis left;
 plot(hours_t1, Qf, 'k-.', 'LineWidth', 1);
 % plot(hours_t3, Qf3, 'k-.', 'LineWidth', 1);
 % plot(hours_t4, Qf4, 'k-.', 'LineWidth', 0.5);


% % % Add constant error bars
% % errorbar(hours_x, Qf, errorValues, 'Vertical', 'b', 'LineWidth', 0.5);
% % errorbar(hours_x, Qf1, errorValues, 'Vertical', 'Color', [1 0.5 0], 'LineWidth', 0.5);
% % errorbar(hours_x2, Qf2_ul, errorValues1, 'Vertical', 'k', 'LineWidth', 0.5);

% Add a title and labels
title('Flow rate profile EXP105 R1 4434-beads WS Yellow'); %Flow rate/pressure profile BS orange sensor resistance 
xlabel('Perfusion time (hrs)');
legend('Flow (uL/min)',  'Filtered flow (uL/min) ','Pressure (mbar)');
grid on
% legend ('BS-orange','S-blue','WS-yellow'); %'S-blue'
%legend ('Not effective sealing','Effective self-sealing- 4434','Effective self-sealing- liver','Pressure'); %'S-blue'


% Set the x-axis limits
%x_min = 0;
%x_max = 6;
%xlim([x_min, x_max]);

% % Set the limits for the primary (left) y-axis
% y_min = -50;
% y_max = 50;
% yyaxis left;
% ylim([y_min, y_max]);

%Set the limits for the secondary (right) y-axis
y2_min = 0;
y2_max = 150;
yyaxis right;
ylim([y2_min, y2_max]);
% ylabel('Applied pressure (mbar)');

%% trapz rule for calculation of volume under the curve
V=trapz(mins_t1,f)/1000 % + (1.6*max(mins_t1)/1000)
% f_final=f(end)
% 
% A=226; %mm2
% rho=0.000001; %kg/mm3
% g=9810; %mm/s2
% R_BS_O= 0.019109487; %(kg/mms2)/(mm3/s)
% R_S_B= 0.026219993; 
% h_mm=((V/1000)/A)*2 %Times 2 because the total h different is double
% %vnL=V*60 %nL
% time=(mins_t1(end)-mins_t1(14080)) %min
% deltaflow=(f(end)-f(14080)) % nL/min
% dQ=(-((rho*g)/R_BS_O)*h_mm)*60*1000 %nL/min

%% Plot differential Flow
% Plot the original function and its derivative
figure;
subplot(3,1,1);
plot(t1, f);
title('Original Function');
ylabel ('Flow rate (nL/min)')

subplot(3,1,2);
plot(t1(1:end-1), df_dt);
ylabel ('dF/dt (nL/min/sec)')
yyaxis right
plot(t1(1:end-1), Qdf_dt);
title('Derivative of Flow rate');
ylabel ('filtered dF/dt ((nL/min)/sec)')
% y_min = -30000;
% y_max = 30000;
% ylim([y_min, y_max]);

subplot(3,1,3);
plot(t1,f_abs);
title('Absolute of flow rate');
ylabel ('Flow rate (nL/min)')


xlabel('Time (Sec)');

%% collection of points for analysis based on dQ/dt
% Define the range you are interested in
threshold = 20;
time_interval=500;

% Use logical indexing to select data points within the specified range
selected_indices = (Qdf_dt >= threshold); 
selected_Qdf_dt = Qdf_dt(selected_indices);
selected_t1 = t1(selected_indices);
selcted_f=f(selected_indices);



% Initialize arrays to store results
all_maxQdf_dt = [];
all_maxQdf_dt_indices = [];

% Initialize variables for tracking intervals
    current_interval_start = 1;
% Iterate through intervals
while current_interval_start < length(t1)
    % Initialize variables to find consecutive t1 values until rounded difference is 1000
    current_interval_end = current_interval_start + 1;

    % Continue finding consecutive t1 values until the rounded difference is 1000
    while round(t1(current_interval_end) - t1(current_interval_start)) < time_interval && current_interval_end < length(t1)
        current_interval_end = current_interval_end + 1;
    end

    % Check if the rounded difference is at least 100
    if round(t1(current_interval_end) - t1(current_interval_start)) == time_interval
  
    % Extract data within the current interval
    subrange_t1 = t1(current_interval_start:current_interval_end);
    subrange_Qdf_dt = Qdf_dt(current_interval_start:current_interval_end);

    % Find peaks above the threshold in the current interval
    [max_Qdf_dt, max_Qdf_dt_indices] = max(subrange_Qdf_dt);
    % Check if the maximum value is above the threshold
    if max_Qdf_dt > threshold
    % Adjust peak indices to correspond to the original data
    max_Qdf_dt_indices = max_Qdf_dt_indices + current_interval_start - 1;

    % Store the results
    all_maxQdf_dt = [all_maxQdf_dt, max_Qdf_dt];
    all_maxQdf_dt_indices = [all_maxQdf_dt_indices,  max_Qdf_dt_indices];

    end
     % Update the start index for the next interval
        current_interval_start = current_interval_end + 1;
 else
    % Increment the start index if the rounded difference is not equal to 1000
              current_interval_start = current_interval_start + 1;   
    end


        % If the final interval is smaller than 1000, take the last maximum from that smaller interval
        if current_interval_end > current_interval_start
            % Extract data within the current interval
             subrange_t1 = t1(current_interval_start:current_interval_end-1);
             subrange_Qdf_dt = Qdf_dt(current_interval_start:current_interval_end-1);


            % Find the maximum value and its index in the current interval
             [max_Qdf_dt, max_Qdf_dt_indices] = max(subrange_Qdf_dt);

            % Check if the maximum value is above the threshold
            if max_Qdf_dt > threshold
             % Adjust peak indices to correspond to the original data
                max_Qdf_dt_indices = max_Qdf_dt_indices + current_interval_start - 1;

                % Store the results
               all_maxQdf_dt = [all_maxQdf_dt, max_Qdf_dt];
                all_maxQdf_dt_indices = [all_maxQdf_dt_indices,  max_Qdf_dt_indices];

         % Exit the loop since we've processed the last interval
        break;


            end
       end
end
    
    
  
% Display the result
disp('Indices of Peaks above Threshold in Defined Intervals:');
disp(all_maxQdf_dt_indices);
disp('Values of Peaks above Threshold in Defined Intervals:');
disp( all_maxQdf_dt);

% select flow values
selected_maxf=f(all_maxQdf_dt_indices);
selected_maxt1=t1(all_maxQdf_dt_indices);
disp('Values of Peak flow rates above Threshold in Defined Intervals:');
disp( selected_maxf);
disp('t1 values at Detected Peak Indices:');
disp(t1(all_maxQdf_dt_indices));
%Plot the original function and its derivative
figure;
subplot(3,1,1);
plot(t1, f);
title('Original Function of Flow rate');
ylabel ('Flow rate (nL/min)')

hold on
plot (t1(all_maxQdf_dt_indices),f(all_maxQdf_dt_indices), 'ro', 'MarkerSize', 10);

subplot(3,1,2);
plot(selected_t1, selcted_f,'bo');
title('Selected flow rates above threshold');
ylabel ('Flow rate (nL/min)')

hold on
plot (t1(all_maxQdf_dt_indices),f(all_maxQdf_dt_indices), 'ro', 'MarkerSize', 10);

subplot(3,1,3);
plot(selected_t1, selected_Qdf_dt,'r*');
title('dF/dt above threshold and maximum points');
ylabel ('dF/dt ((nL/min)/sec)')

hold on
plot(t1(all_maxQdf_dt_indices),Qdf_dt( all_maxQdf_dt_indices), 'bo', 'MarkerSize', 10);

% y_min = -30000;
% y_max = 30000;
% ylim([y_min, y_max]);

xlabel('Time (Sec)');


%% collection of points for analysis based on flow

threshold1 = 430;
% Define the target interval size
target_interval_size =200;

% Use logical indexing to select data points within the specified range
selected_indices = (f_abs >= threshold1);
selected_f = f(selected_indices);
selected_t1 = t1(selected_indices);

% Initialize arrays to store results
all_maxf = [];
all_maxf_indices = [];


% Initialize variables for tracking intervals
current_interval_start1 = 1;


% Iterate through intervals
while current_interval_start1 < length(t1)
    % Find consecutive t1 values until rounded difference is close to target_interval_size
    current_interval_end1 = current_interval_start1;
    while current_interval_end1 < length(t1) && round(t1(current_interval_end1 + 1) - t1(current_interval_start1)) < target_interval_size
        current_interval_end1 = current_interval_end1 + 1;
    end

    % Extract data within the current interval
    subrange_t1f = t1(current_interval_start1:current_interval_end1);
    subrange_f = f_abs(current_interval_start1:current_interval_end1);

    % Find peaks above the threshold
    [peaks, locations] = findpeaks(subrange_f, 'MinPeakHeight', threshold1);

    % Convert peak data to double if not already
    peaks = double(peaks);

    % Check if any peaks were found
    if ~isempty(peaks) %% if it not empty
        % Check if any of the peak values are above the threshold
        above_threshold_indices = find(peaks > threshold1);
        if ~isempty(above_threshold_indices)
            % Find all peaks above the threshold
            allPeaks = peaks(above_threshold_indices);

            % Find the indices corresponding to all peaks above the threshold
            allPeakIndicesInOriginalData = locations(above_threshold_indices) + (current_interval_start1 - 1);

            % Find the maximum peak value among all peaks above the threshold
            maxPeak = max(allPeaks);

            % Find the index corresponding to the maximum peak value
            maxPeakIndexInOriginalData = allPeakIndicesInOriginalData(allPeaks == maxPeak);

            % Store the results
            all_maxf = [all_maxf, maxPeak];
            all_maxf_indices = vertcat(all_maxf_indices, maxPeakIndexInOriginalData);
        end
    end

    % Update the start index for the next interval
    current_interval_start1 = current_interval_end1 + 1;
end

% Display the result
disp('Corresponding indices:');
disp(all_maxf_indices);
disp('Detected peaks:');
disp(all_maxf);

% Extract flow values using all_maxf_indices
extracted_flow_values = f(all_maxf_indices);

% Display the extracted flow values and compare with all_maxf
disp('Extracted Flow Values Using all_maxf_indices:');
disp(extracted_flow_values);
disp('t1 values at Detected Peak Indices:');
disp(t1(all_maxf_indices));
disp('Qf values at Detected Peak Indices:');
disp(Qf(all_maxf_indices));

% Plot the original function and its derivative
figure;
subplot(4, 1, 1);
plot(t1, f);
title('Original Function of Flow rate');
ylabel('Flow rate (nL/min)')

hold on
plot(t1(all_maxf_indices), f(all_maxf_indices), 'ro', 'MarkerSize', 10);
plot(t1, Qf,'g');

subplot(4, 1, 2);
plot(t1, f_abs);
title('Absolute Flow rate');
ylabel('Flow rate (nL/min)')
hold on
plot(t1(all_maxf_indices), f_abs(all_maxf_indices), 'ro', 'MarkerSize', 10);

subplot(4,1,3)

plot(selected_t1, selected_f, 'bo');
title('Selected flow rates above threshold');
ylabel('Flow rate (nL/min)')
hold on
plot(t1(all_maxf_indices), f(all_maxf_indices), 'ro', 'MarkerSize', 10);

subplot(4,1,4)

plot(t1,Qf, 'b');
title('Selected flow rates above threshold');
ylabel('Flow rate (nL/min)')
hold on
plot(t1(all_maxf_indices), Qf(all_maxf_indices), 'ro', 'MarkerSize', 10);

xlabel('Time (Sec)');
%% collect flow data for analysis based on dQ/dt data
% % Number of points to average (adjust as needed)
num_points_to_average = 3200; % more or less 1 minute of data

% Initialize an array to store the averages
average_flow = zeros(1, length(all_maxQdf_dt_indices));
std_deviation_flow = zeros (1,length(all_maxQdf_dt_indices));
slope_flowf = zeros(1, length(all_maxQdf_dt_indices));
slope_flowQf = zeros(1, length(all_maxQdf_dt_indices));
average_Qf = zeros(1, length(all_maxQdf_dt_indices));
slope_mdl = zeros(1, length(all_maxQdf_dt_indices));
slope_mdl_Qf = zeros(1, length(all_maxQdf_dt_indices));

% Initialize an array to store the averages
average_flow = zeros(1, length(all_maxQdf_dt_indices));
std_deviation_flow = zeros (1,length(all_maxQdf_dt_indices));
% Iterate through the stored indices
for i = 1:length(all_maxQdf_dt_indices)
    % Get the current index
    current_index = all_maxQdf_dt_indices(i)
    
    % Check if there are at least 100 points before the current index
    if current_index >= num_points_to_average
        % Extract the last 100 points within the range
        range_data = f(current_index - num_points_to_average + 1:current_index-100);
        range_time = t1(current_index - num_points_to_average + 1:current_index-100);
        range_dataQf = Qf(current_index - num_points_to_average +1 :current_index-200);
        range_timeQf = t1(current_index - num_points_to_average + 1:current_index-200);
        
        % Calculate the average for the current range
        average_flow(i) = mean(range_data);
        std_deviation_flow(i) = std(range_dataQf);
        average_Qf(i)= mean(range_dataQf);
        mdl_slope=fitlm(range_time,range_data);
        mdl_slope_Qf=fitlm(range_timeQf,range_dataQf);
        % Calculate the slope (delta_flow over delta_t) for the current range
        delta_flow = range_data(end) - range_data(1);
        delta_t = range_time(end) - range_time(1);
        slope_flowf(i) = (delta_flow / delta_t)*60;
        delta_flowQf = range_dataQf(end) - range_dataQf(1);
        delta_Qft = range_timeQf(end) - range_timeQf(1);
        slope_flowQf(i) = (delta_flowQf / delta_Qft)*40;
        slope_mdl(i)=mdl_slope.Coefficients.Estimate(2)*60;
        slope_mdl_Qf(i)=mdl_slope_Qf.Coefficients.Estimate(2)*40;
    else
        % If there are fewer than x points, set the average to NaN
        average_flow(i) = NaN;
        std_deviation_flow(i) = NaN;
        slope_flowf(i) = NaN;
        slope_flowQf(i) = NaN;
        slope_mdl(i)=NaN;
        slope_mdl_Qf(i)=NaN;
    end
end
% Extract the last 100 points within the range from the final point
f_final = f(end)  
f_final_index = length(f)
range_data2 = f(f_final_index- num_points_to_average + 1:f_final_index-100);
range_time2 = t1(f_final_index - num_points_to_average + 1:f_final_index-100);
range_dataQf2 = Qf(f_final_index - num_points_to_average + 1:f_final_index-100);
% Calculate the average for the current range
average_flow2 = mean(range_data2)
std_deviation_flow2 = std(range_data2)
% Calculate the slope (delta_flow over delta_t) for the current range
delta_flow2 = range_dataQf2(end) - range_dataQf2(1);
delta_t2 = range_time2(end) - range_time2(1);
slope_flow2 = (delta_flow2 / delta_t2)*70;

% % Extract specific point from data set not captured by code _ change f(x)
% % with index of datapoint of interest
% f_specific= f(444958);
% range_data3 = f(444958- num_points_to_average + 1:444958-4620);
% % Calculate the average for the current range
% average_flow3 = mean(range_data3)
% std_deviation_flow3 = std(range_data3)

% Display or use the calculated averages
disp('Average of the last minute within each step - flow:');
disp(average_flow);
disp('Standard Deviation of the last minute within each step - flow:');
disp(std_deviation_flow);
disp('Average Qf of the last minute within each step - flow:');
disp(average_Qf);
% Display or use the calculated averages and slopes
disp('Slope (delta_flow over delta_t) of the last minute within each step - flow:');
disp(slope_flowf);
% Display or use the calculated averages and slopes
disp('Slope (delta_flowQf over delta_tQf) of the last minute within each step - flow:');
disp(slope_flowQf);
% Display or use the calculated averages and slopes
disp('Slope (mdl) of the last minute within each step - flow:');
disp(slope_mdl);
% Display or use the calculated averages and slopes
disp('Slope (mdl_Qf) of the last minute within each step - flow:');
disp(slope_mdl_Qf);

%% collect flow data for analysis based on flow-selected data
% % Number of points to average (adjust as needed)
num_points_to_average = 3600; % more or less 1 minute of date

% Initialize an array to store the averages
average_flowf = zeros(1, length(all_maxf_indices));
std_deviation_flowf = zeros (1,length(all_maxf_indices));
slope_flowf = zeros(1, length(all_maxf_indices));
slope_flowQf = zeros(1, length(all_maxf_indices));
average_Qf = zeros(1, length(all_maxf_indices));
slope_mdl = zeros(1, length(all_maxf_indices));
slope_mdl_Qf = zeros(1, length(all_maxf_indices));
% Iterate through the stored indices
for i = 1:length(all_maxf_indices)
    % Get the current index
    current_index = all_maxf_indices(i);
    
    % Check if there are at least 100 points before the current index
    if current_index >= num_points_to_average
        % Extract the last 100 points within the range
        range_data1 = f(current_index - num_points_to_average + 1:current_index-600);
        range_time1 = t1(current_index - num_points_to_average + 1:current_index-600);
        range_dataQf1 = Qf(current_index - num_points_to_average +1 :current_index-800);
        range_timeQf1 = t1(current_index - num_points_to_average + 1:current_index-800);
        % Calculate the average for the current range
        average_flowf(i) = mean(range_data1);
        std_deviation_flowf(i) = std(range_dataQf1); %!!!!
        average_Qf(i)= mean(range_dataQf1);
        mdl_slope=fitlm(range_time1,range_data1);
        mdl_slope_Qf=fitlm(range_timeQf1,range_dataQf1);
        % Calculate the slope (delta_flow over delta_t) for the current range
        delta_flow = range_data1(end) - range_data1(1);
        delta_t = range_time1(end) - range_time1(1);
        slope_flowf(i) = (delta_flow / delta_t)*300;
        delta_flowQf = range_dataQf1(end) - range_dataQf1(1);
        delta_Qft = range_timeQf1(end) - range_timeQf1(1);
        slope_flowQf(i) = (delta_flowQf / delta_Qft)*280;
        slope_mdl(i)=mdl_slope.Coefficients.Estimate(2)*300;
        slope_mdl_Qf(i)=mdl_slope_Qf.Coefficients.Estimate(2)*280;
    else
        % If there are fewer than x points, set the average to NaN
        average_flowf(i) = NaN;
        std_deviation_flowf(i) = NaN;
        slope_flowf(i) = NaN;
        slope_flowQf(i) = NaN;
        slope_mdl(i)=NaN;
        slope_mdl_Qf(i)=NaN;
    end
end
% Extract the last 100 points within the range from the final point
f_final = f(end)  ;
f_final_index = length(f);
range_data2 = f(f_final_index- num_points_to_average + 1:f_final_index-100);
range_time2 = t1(f_final_index - num_points_to_average + 1:f_final_index-100);
range_dataQf2 = Qf(f_final_index - num_points_to_average + 1:f_final_index-100);
% Calculate the average for the current range
average_flow2 = mean(range_data2)
std_deviation_flow2 = std(range_data2)
% Calculate the slope (delta_flow over delta_t) for the current range
delta_flow2 = range_dataQf2(end) - range_dataQf2(1);
delta_t2 = range_time2(end) - range_time2(1);
slope_flow2 = (delta_flow2 / delta_t2)*60;

% % Extract specific point from data set not captured by code _ change f(x)
% % with index of datapoint of interest
% f_specific= f(444958);
% range_data3 = f(444958- num_points_to_average + 1:444958-4620);
% % Calculate the average for the current range
% average_flow3 = mean(range_data3)
% std_deviation_flow3 = std(range_data3)

% Display or use the calculated averages
disp('Average of the last minute within each step - flow:');
disp(average_flowf);
disp('Average Qf of the last minute within each step - flow:');
disp(average_Qf);
disp('Standard Deviation of the last minute within each step - flow:');
disp(std_deviation_flowf);
% Display or use the calculated averages and slopes
disp('Slope (delta_flow over delta_t) of the last minute within each step - flow:');
disp(slope_flowf);
% Display or use the calculated averages and slopes
disp('Slope (delta_flowQf over delta_tQf) of the last minute within each step - flow:');
disp(slope_flowQf);
% Display or use the calculated averages and slopes
disp('Slope (mdl) of the last minute within each step - flow:');
disp(slope_mdl);
% Display or use the calculated averages and slopes
disp('Slope (mdl_Qf) of the last minute within each step - flow:');
disp(slope_mdl_Qf);

%% Plot differential pressure
% Plot the original function and its derivative
figure;
subplot(2,1,1);
plot(t, p);
y_min = -30;
y_max = 130;
ylim([y_min, y_max]);
title('Original Function of pressure');
ylabel ('Applied pressure (mbar)')

subplot(2,1,2);
plot(t(1:end-1), dp_dt);
title('Derivative of pressure');
ylabel ('dp/dt (mbar/sec)')
y_min = 0;
y_max = 30;
ylim([y_min, y_max]);


xlabel('Time');

%% collection of points for analysis - pressure
% Define the range you are interested in
threshold = 3.05;
time_interval_p=200;
% Use logical indexing to select data points within the specified range
selected_indices = (dp_dt >= threshold); 
selected_dp_dt = dp_dt(selected_indices);
selected_t = t(selected_indices);
selcted_p=p(selected_indices);



% Initialize arrays to store results
all_maxdp_dt = [];
all_maxdp_dt_indices = [];

% Initialize variables for tracking intervals
    current_interval_start_p = 1;
% Iterate through intervals
while current_interval_start_p < length(t)
    % Initialize variables to find consecutive t1 values until rounded difference is 1000
    current_interval_end_p = current_interval_start_p + 1;

    % Continue finding consecutive t1 values until the rounded difference is 1000
    while round(t(current_interval_end_p) - t(current_interval_start_p)) < time_interval_p && current_interval_end_p < length(t)
        current_interval_end_p = current_interval_end_p + 1;
    end

    % Check if the rounded difference is at least 1000
    if round(t(current_interval_end_p) - t(current_interval_start_p)) == time_interval_p
    % Extract data within the current interval
    subrange_t = t(current_interval_start_p:current_interval_end_p);
    subrange_dp_dt = dp_dt(current_interval_start_p:current_interval_end_p);

    % Find peaks above the threshold in the current interval
    [max_dp_dt, max_dp_dt_indices] = max(subrange_dp_dt);
    % Check if the maximum value is above the threshold
    if max_dp_dt > threshold
    % Adjust peak indices to correspond to the original data
    max_dp_dt_indices = max_dp_dt_indices + current_interval_start_p - 1;

    % Store the results
    all_maxdp_dt = [all_maxdp_dt, max_dp_dt];
    all_maxdp_dt_indices = [all_maxdp_dt_indices,  max_dp_dt_indices];

    end
     % Update the start index for the next interval
        current_interval_start_p = current_interval_end_p + 1;
 else
    % Increment the start index if the rounded difference is not equal to 1000
              current_interval_start_p = current_interval_start_p + 1;   
    end


        % If the final interval is smaller than 100, take the last maximum from that smaller interval
        if current_interval_end_p > current_interval_start_p
            % Extract data within the current interval
             subrange_t = t(current_interval_start_p:current_interval_end_p-1);
             subrange_dp_dt = dp_dt(current_interval_start_p:current_interval_end_p-1);


            % Find the maximum value and its index in the current interval
             [max_dp_dt, max_dp_dt_indices] = max(subrange_dp_dt);

            % Check if the maximum value is above the threshold
            if max_dp_dt > threshold
             % Adjust peak indices to correspond to the original data
                max_dp_dt_indices = max_dp_dt_indices + current_interval_start_p - 1;

                % Store the results
               all_maxdp_dt = [all_maxdp_dt, max_dp_dt];
               all_maxdp_dt_indices = [all_maxdp_dt_indices,  max_dp_dt_indices];

         % Exit the loop since we've processed the last interval
        break;


            end
       end
end
    
    
  
% Display the result
disp('Indices of Peaks above Threshold in Defined Intervals:');
disp(all_maxdp_dt_indices);
disp('Values of Peaks above Threshold in Defined Intervals:');
disp( all_maxdp_dt);
disp ('t at peak values');
disp (t(all_maxdp_dt_indices))

% select flow values
selected_maxp=p(all_maxdp_dt_indices);
selected_maxt=t(all_maxdp_dt_indices);
disp('Values of Peak flow rates above Threshold in Defined Intervals:');
disp( selected_maxp);
%Plot the original function and its derivative
figure;
subplot(3,1,1);
plot(t, p);
title('Original Function');
ylabel ('Applied pressure (mbar)')
y_min = -30;
y_max = 130;
ylim([y_min, y_max]);

hold on
plot (t(all_maxdp_dt_indices),p(all_maxdp_dt_indices), 'ro', 'MarkerSize', 10);

subplot(3,1,2);
plot(selected_t, selcted_p,'bo');
title('Selected applied pressures above threshold');
ylabel ('Pressure (mbar)')

hold on
plot (t(all_maxdp_dt_indices),p(all_maxdp_dt_indices), 'ro', 'MarkerSize', 10);

subplot(3,1,3);
plot(selected_t, selected_dp_dt,'r*');
ylabel ('dp/dt (mbar/min)')

hold on
plot(t(all_maxdp_dt_indices),dp_dt( all_maxdp_dt_indices), 'bo', 'MarkerSize', 10);


xlabel('Time');

%% collect pressure data for analysis
% % Number of points to average (adjust as needed)
num_points_to_average_p = 800; % more or less 1 minute of date

% Initialize an array to store the averages
average_pressure = zeros(1, length(all_maxdp_dt_indices));
std_deviation_pressure = zeros (1,length(all_maxdp_dt_indices));
% Iterate through the stored indices
for i = 1:length(all_maxdp_dt_indices)
    % Get the current index
    current_index_p = all_maxdp_dt_indices(i);
    
    % Check if there are at least 100 points before the current index
    if current_index_p >= num_points_to_average_p;
        % Extract the last 100 points within the range
        range_data_p = p(current_index_p - num_points_to_average_p + 1:current_index_p-100); % change
        
        % Calculate the average for the current range
        average_pressure(i) = mean(range_data_p);
        std_deviation_pressure(i) = std(range_data_p);
    else
        % If there are fewer than 100 points, set the average to NaN
        average_pressure(i) = NaN;
        std_deviation_pressure(i) = NaN;
    end
end
% Extract the last 100 points within the range from the final point
p_final = p(end)  
p_final_index = length(p)
range_data3 = p(p_final_index- num_points_to_average_p + 1:p_final_index-100);
        
% Calculate the average for the current range
average_pressure2 = mean(range_data3)
std_deviation_pressure2 = std(range_data3)

% Display or use the calculated averages
disp('Average of the last minute within each step - pressure:');
disp(average_pressure);
disp('Standard Deviation of the last minute within each step - pressure:');
disp(std_deviation_pressure);

%% plot scatterplot for pressure vs flow rate without offset - do this such that offset is included
% change between average_flow to average_flowf depending on collection of data based on dQ/dt or absolute f respectively 
average_flow1 =horzcat(average_flowf(1,[2,4,6,22])); 
average_pressure1 = horzcat(average_pressure(1,[2,4,6,20]));
std_deviation_flow1=horzcat(std_deviation_flowf(1,[2,4,6,22]));
std_deviation_pressure1=horzcat(std_deviation_pressure(1,[2,4,6,20]));
average_pressure_off= average_pressure1+28.63
% %Plot DP over Q !(for single cycle data)!
% figure
% errorbar(average_flow1,average_pressure1,  std_deviation_pressure1,std_deviation_pressure1,std_deviation_flow1, std_deviation_flow1,'o', 'MarkerSize', 4, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'b', 'LineWidth', 0.5);
% 
% hold on
% y_min =min(average_pressure1)-5;
% y_max =75;
% ylim([y_min, y_max]);
% x_min = min(average_flow1)-20;
% x_max = 1000; % x_max 6000 when measuring flow sensor resistance
% xlim([x_min, x_max]);
% % Fit a linear polynomial (degree 1) to the data
% p = polyfit(average_flow1, average_pressure1, 1);
% 
% % Evaluate the fitted polynomial over a range of x values
% yFit = polyval(p, average_flow1);
% 
% mdl_pvq=fitlm(average_flow1, average_pressure1)
% 
% 
% % % ft2 = fittype({'x'});
% % % p2 = fit(average_flow1',average_pressure1',ft2);
% % % x_fit = linspace(0,140,11); %x-values to evaluate
% % % y2_fitted = feval(p2, x_fit); %y-values for the evaluated x-values
% % % slope = y2_fitted(11)./x_fit(11);
% % % 
% % 
% % Plot the fitted line
% plot(average_flow1, yFit, 'b-', 'LineWidth',0.5);
% % plot(x_fit,y2_fitted,'r--')
% plot(mdl_pvq)
% 
% legend('Datapoints','Random Intercept', 'Location','northwest');
% 
% 
% % Calculate R-squared value - change to average flow (without 1 if you
% % include 0 mbar data
% yFit = polyval(p, average_flow1);
% yMean = mean(average_pressure1);
% SSR = sum((yFit - yMean).^2);
% SSE = sum((average_pressure1 - yFit).^2);
% R2 = SSR / (SSR + SSE);
% 
% % yMean_1 = mean(average_pressure1);
% % SSR_1 = sum((y2_fitted - yMean_1).^2);
% % SSE_1 = sum((average_pressure1 - y2_fitted').^2);
% % R2_1 = SSR_1 / (SSR_1 + SSE_1);
% 
% % Display R-squared value on the plot
% txt = sprintf('R^2 = %.4f', R2);
% annotation('textbox', [0.6,0.6,0.01,0.02],'String', txt, 'FitBoxToText', 'on', 'BackgroundColor', 'white');
% txt1 = sprintf('ΔP = %.4f Q (+) %.4f', p);
% annotation('textbox',[0.6,0.7,0.01,0.02],  'String', txt1, 'FitBoxToText', 'on', 'BackgroundColor', 'white');
% 
% % txt2 = sprintf('ΔP = %.4f Q ', slope);
% % annotation('textbox',[0.6,0.5,0.01,0.02], 'String', txt2, 'FitBoxToText', 'on', 'BackgroundColor', 'red');
% % txt2 = sprintf('R^2 = %.4f', R2_1);
% % annotation('textbox',[0.6,0.4,0.01,0.02], 'String', txt2, 'FitBoxToText', 'on', 'BackgroundColor', 'red');
% hold off
% 
% % % Define colors for different cycles
% % colors = {'b', [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330]}; %, [0.9290 0.6940 0.1250]};
% % 
% % % Preallocate storage for p and R2
% % p_values = cell(1, 3); % Store p values for each cycle
% % R2_values = zeros(1, 3); % Store R2 values for each cycle
% % 
% % % Preallocate cell array to store linear model objects
% % mdl_pvq = cell(1, 3);
% % legend_handles = gobjects(1, 3); % Preallocate array for legend handles
% % 
% % % Plot DP over Q for each pressure step cycle
% % figure;
% % hold on;
% % for cycle = 1:3
% %     indices = (cycle - 1) * 6 + (1:6);
% %     scatter_handles=errorbar(average_flow1(indices), average_pressure1(indices), ...
% %              std_deviation_pressure1(indices), std_deviation_pressure1(indices), ...
% %              std_deviation_flow1(indices), std_deviation_flow1(indices), ...
% %              'o', 'MarkerSize', 5, 'MarkerFaceColor', colors{cycle}, ...
% %              'MarkerEdgeColor', colors{cycle}, 'LineWidth', 0.5,'DisplayName', sprintf('Cycle %d', cycle));
% % 
% %     % Fit linear model
% %     mdl_pvq{cycle} = fitlm(average_flow1(indices), average_pressure1(indices));
% % 
% %     % Calculate R-squared value
% %     p = polyfit(average_flow1(indices), average_pressure1(indices), 1);
% %     yFit = polyval(p, average_flow1(indices));
% %     yMean = mean(average_pressure1(indices));
% %     SSR = sum((yFit - yMean).^2);
% %     SSE = sum((average_pressure1(indices) - yFit).^2);
% %     R2 = SSR / (SSR + SSE);
% % 
% %     % Plot linear model
% %     plot(mdl_pvq{cycle}, 'DisplayName', sprintf('Linear Fit, Cycle %d', cycle));
% %     % Plot the fitted line
% %     plot(average_flow1(indices), yFit, 'Color',colors{cycle},'Linestyle','-', 'LineWidth',1, 'DisplayName', sprintf('Fitted Line, Cycle %d', cycle));
% % 
% %     % Store p and R2 values
% %     p_values{cycle} = p;
% %     R2_values(cycle) = R2;
% % 
% %      % Define annotation positions based on cycle number
% %     x_pos = 0.6;
% %     y_pos_txt = 0.6 - (cycle - 1) * 0.1;
% %     y_pos_txt1 = 0.7 - (cycle - 1) * 0.1;
% % 
% %     % Display R-squared value and equation of the linear fit on the plot
% %     txt = sprintf('R^2 = %.4f', R2);
% %     annotation('textbox', [x_pos, y_pos_txt, 0.01, 0.02],'String', txt, 'FitBoxToText', 'on', 'BackgroundColor', colors{cycle});
% %     txt1 = sprintf('ΔP = %.4f Q (+) %.4f', p(1), p(2));
% %     annotation('textbox',[x_pos, y_pos_txt1, 0.01, 0.02],  'String', txt1, 'FitBoxToText', 'on', 'BackgroundColor', colors{cycle});
% % 
% %     % Store handles for legend
% %     legend_handles(cycle) = scatter_handles;
% % end
% % hold off;
% % legend(legend_handles,'Location','best')
% % 
% % % Displaying the models and values
% % for cycle = 1:3
% %     disp(['Model pvq for cycle ', num2str(cycle)]);
% %     disp(mdl_pvq{cycle});
% %     disp(['p values for cycle ', num2str(cycle)]);
% %     disp(p_values{cycle});
% %     disp(['R2 value for cycle ', num2str(cycle)]);
% %     disp(R2_values(cycle));
% % end
% 
% title('Pressure over flow rate WS-Y capillary sensor with adjustment')
% ylabel ('Applied pressure (mbar)')
% xlabel ('Flow rate (nL/min)')
% 
% 
% % Format the results as a string
% resultString = sprintf('Analysis Results:\n');
% resultString = sprintf('%sHydrodynamic Resistance (mbar/nL/min): %.4f\n', resultString, p(1,1));
% resultString = sprintf('%sIntercept (mbar): %.4f\n', resultString, p(1,2));
% 
% % Display the results in a pop-up window
% msgbox(resultString, 'Analysis Results');
% 
% %Plot Q over DP !(for single cycle data)!
% figure
% errorbar(average_pressure1, average_flow1, std_deviation_flow1, std_deviation_flow1,std_deviation_pressure1 ,std_deviation_pressure1,  'o', 'MarkerSize', 4, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'b', 'LineWidth', 0.5);
% hold on
% 
% y_min =min(average_flow1)-20; 
% y_max = 1000;
% ylim([y_min, y_max]);
% x_min = min(average_pressure1)-5;
% x_max = 150;
% xlim([x_min, x_max]);
% % Fit a linear polynomial (degree 1) to the data
% p_qvp = polyfit(average_pressure1,average_flow1, 1);
% 
% % Evaluate the fitted polynomial over a range of x values
% yFit_qvp = polyval(p_qvp, average_pressure1);
% 
% mdl_qvp=fitlm(average_pressure1,average_flow1)
% 
% % Plot the fitted line
% plot(average_pressure1, yFit_qvp, 'b-', 'LineWidth',0.5);
% plot(mdl_qvp)
% 
% legend('Datapoints','Random Intercept', 'Location','northwest');
% 
% % Calculate R-squared value - change to average flow (without 1 if you
% % include 0 mbar data
% yMean = mean(average_flow1);
% SSR = sum((yFit_qvp - yMean).^2);
% SSE = sum((average_flow1 - yFit_qvp).^2);
% R2_qvp_off = SSR / (SSR + SSE);
% 
% % Display R-squared value on the plot
% txt = sprintf('R^2 = %.4f', R2);
% annotation('textbox', [0.6,0.6,0.01,0.02],'String', txt, 'FitBoxToText', 'on', 'BackgroundColor', 'white');
% txt1 = sprintf('Q = %.4f ΔP (+) %.4f', p_qvp);
% annotation('textbox',[0.6,0.7,0.01,0.02],  'String', txt1, 'FitBoxToText', 'on', 'BackgroundColor', 'white');
% 
% % % Preallocate storage for p and R2
% % p_values_qvp = cell(1, 3); % Store p values for each cycle
% % R2_values_qvp = zeros(1, 3); % Store R2 values for each cycle
% % 
% % % Preallocate cell array to store linear model objects
% % mdl_qvp = cell(1, 3);
% % legend_handles = gobjects(1, 3); % Preallocate array for legend handles
% % 
% % % Plot Q over DP for each pressure step cycle
% % figure;
% % hold on;
% % for cycle = 1:3
% %     indices = (cycle - 1) * 6 + (1:6);
% %     scatter_handles_qvp=errorbar(average_pressure1(indices), average_flow1(indices),...
% %              std_deviation_flow1(indices), std_deviation_flow1(indices), ...
% %              std_deviation_pressure1(indices), std_deviation_pressure1(indices), ...
% %              'o', 'MarkerSize', 5, 'MarkerFaceColor', colors{cycle}, ...
% %              'MarkerEdgeColor', colors{cycle}, 'LineWidth', 0.5,'DisplayName', sprintf('Cycle %d', cycle));
% % 
% %     % Fit linear model
% %     mdl_qvp{cycle} = fitlm(average_pressure1(indices),average_flow1(indices));
% % 
% %     % Calculate R-squared value
% %     p_qvp = polyfit(average_pressure1(indices), average_flow1(indices),1);
% %     yFit_qvp = polyval(p_qvp, average_pressure1(indices));
% %     yMean = mean(average_flow1(indices));
% %     SSR = sum((yFit_qvp - yMean).^2);
% %     SSE = sum((average_flow1(indices) - yFit_qvp).^2);
% %     R2_qvp = SSR / (SSR + SSE);
% % 
% %     % Plot linear model
% %     plot(mdl_qvp{cycle}, 'DisplayName', sprintf('Linear Fit, Cycle %d', cycle));
% %     % Plot the fitted line
% %     plot(average_pressure1(indices), yFit_qvp, 'Color',colors{cycle},'Linestyle','-', 'LineWidth',1, 'DisplayName', sprintf('Fitted Line, Cycle %d', cycle));
% % 
% %     % Store p and R2 values
% %     p_values_qvp{cycle} = p_qvp;
% %     R2_values_qvp(cycle) = R2_qvp;
% % 
% %      % Define annotation positions based on cycle number
% %     x_pos = 0.6;
% %     y_pos_txt = 0.6 - (cycle - 1) * 0.1;
% %     y_pos_txt1 = 0.7 - (cycle - 1) * 0.1;
% % 
% %     % Display R-squared value and equation of the linear fit on the plot
% %     txt = sprintf('R^2 = %.4f', R2_qvp);
% %     annotation('textbox', [x_pos, y_pos_txt, 0.01, 0.02],'String', txt, 'FitBoxToText', 'on', 'BackgroundColor', colors{cycle});
% %     txt1 = sprintf('Q = %.4f ΔP (+) %.4f', p_qvp(1), p_qvp(2));
% %     annotation('textbox',[x_pos, y_pos_txt1, 0.01, 0.02],  'String', txt1, 'FitBoxToText', 'on', 'BackgroundColor', colors{cycle});
% % 
% %     % Store handles for legend
% %     legend_handles(cycle) = scatter_handles_qvp;
% % end
% % hold off;
% % legend(legend_handles,'Location','best')
% % 
% % % Displaying the models and values
% % for cycle = 1:3
% %     disp(['Model qvp for cycle ', num2str(cycle)]);
% %     disp(mdl_qvp{cycle});
% %     disp(['p values for cycle ', num2str(cycle)]);
% %     disp(p_values_qvp{cycle});
% %     disp(['R2 value for cycle ', num2str(cycle)]);
% %     disp(R2_values_qvp(cycle));
% % end
% 
% 
% ylabel ('Flow rate (nL/min)')
% xlabel ('Applied pressure (mbar)')
% title('Flow rate over applied pressure WS-Y capillary with adjustment')

%% Plot resistance over applied pressure
% Calculate local resistance and associate standard deviation
R= average_pressure_off./average_flow1;
std_R = R .* sqrt((std_deviation_flow1 ./ average_flow1).^2 + (std_deviation_pressure1./ average_pressure_off).^2);

figure
errorbar(average_pressure_off, R, std_R, std_R, std_deviation_pressure1, std_deviation_pressure1,'o', 'MarkerSize', 4, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'LineWidth', 0.5);

% % Define colors for different cycles
% colors = {'b', [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330]};%,[0.9290 0.6940 0.1250]};
% 
% figure;
% hold on;
% for cycle = 1:3
%     indices = (cycle - 1) * 6 + (1:6);
%     errorbar(average_pressure1(indices), R(indices), std_R(indices), std_R(indices), ...
%              std_deviation_pressure1(indices), std_deviation_pressure1(indices), ...
%              'o', 'MarkerSize', 5, 'MarkerFaceColor', colors{cycle}, ...
%              'MarkerEdgeColor', colors{cycle}, 'LineWidth', 0.5);
% end

xlabel('ΔP (mbar)');
ylabel('Local Resistance (mbar/nL/min)');
legend('1st cycle','2nd cycle', '3rd cycle','Location','northwest'); %'3rd cycle','4th cycle'
title('Sensurion 4434 2.5mm 37C DMEM N75 ADH R2 WSY R9 + offset');
y_min = 0;
y_max = max(R)+0.5;
ylim([y_min, y_max]);
grid on;


% % Add connecting lines
% hold on;
% plot(average_pressure1(2:end), R(2:end), '-', 'Color', 'k', 'LineWidth', 1);
% hold off;

%% plot considering offset

%Plot DP over Q (single cycle)
figure
errorbar(average_flow1,average_pressure_off,  std_deviation_pressure1 ,std_deviation_pressure1 ,std_deviation_flow1, std_deviation_flow1,'o', 'MarkerSize', 4, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'b', 'LineWidth', 0.5);

hold on

y_min =min(average_pressure_off)-5;
y_max = 150;
ylim([y_min, y_max]);
x_min = min(average_flow1)-5;
x_max = max(average_flow1)+20; % x_max 6000 when measuring flow sensor resistance
xlim([x_min, x_max]);
% Fit a linear polynomial (degree 1) to the data
p_off = polyfit(average_flow1, average_pressure_off, 1);

% Evaluate the fitted polynomial over a range of x values
yFit_off = polyval(p_off, average_flow1);
mdl_pvq_off=fitlm(average_flow1, average_pressure_off)
% 
% ft2 = fittype({'x'});
% p2 = fit(average_flow1',average_pressure1',ft2);
% x_fit = linspace(0,140,3); %x-values to evaluate
% y2_fitted = feval(p2, x_fit); %y-values for the evaluated x-values
% slope = y2_fitted(3)./x_fit(3);
% 

% % Plot the fitted line
% plot(average_flow1, yFit_off, 'b-', 'LineWidth',0.5);
% plot(x_fit,y2_fitted,'r--')
 plot(mdl_pvq_off)

legend('Datapoints','Random Intercept','Location','northwest'); %'Intercept 0'
title('ΔP over Q BSO 4434 2.5mm 37C DMEM N75 ADH R2 WSY R9 + offset')
% Calculate R-squared value - change to average flow (without 1 if you
% include 0 mbar data
yFit_off = polyval(p_off, average_flow1);
yMean = mean(average_pressure_off);
SSR_off = sum((yFit_off - yMean).^2);
SSE_off = sum((average_pressure_off - yFit_off).^2);
R2_off = SSR_off / (SSR_off + SSE_off);

% yMean_1 = mean(average_pressure1);
% SSR_1 = sum((y2_fitted - yMean_1).^2);
% SSE_1 = sum((average_pressure1 - y2_fitted').^2);
% R2_1 = SSR_1 / (SSR_1 + SSE_1);

% Display R-squared value on the plot
txt = sprintf('R^2 = %.4f', R2_off);
annotation('textbox', [0.6,0.6,0.01,0.02],'String', txt, 'FitBoxToText', 'on', 'BackgroundColor', 'white');
txt1 = sprintf('ΔP = %.4f Q (+) %.4f', p_off);
annotation('textbox',[0.6,0.7,0.01,0.02],  'String', txt1, 'FitBoxToText', 'on', 'BackgroundColor', 'white');
% txt2 = sprintf('ΔP = %.4f Q ', slope);
% annotation('textbox',[0.6,0.5,0.01,0.02], 'String', txt2, 'FitBoxToText', 'on', 'BackgroundColor', 'red');
% txt2 = sprintf('R^2 = %.4f', R2_1);
% annotation('textbox',[0.6,0.4,0.01,0.02], 'String', txt2, 'FitBoxToText', 'on', 'BackgroundColor', 'red');

% % Define colors for different cycles
% colors = {'b', [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330]};%,[0.9290 0.6940 0.1250]};
% 
% % Preallocate storage for p and R2
% p_values = cell(1, 3); % Store p values for each cycle
% R2_values = zeros(1, 3); % Store R2 values for each cycle
% 
% % Preallocate cell array to store linear model objects
% mdl_pvq_off = cell(1, 3);
% legend_handles = gobjects(1, 3); % Preallocate array for legend handles
% 
% % Plot DP over Q for each pressure step cycle
% figure;
% hold on;
% for cycle = 1:3
%     indices = (cycle - 1) * 6 + (1:6);
%     scatter_handles=errorbar(average_flow1(indices), average_pressure_off(indices), ...
%              std_deviation_pressure1(indices), std_deviation_pressure1(indices), ...
%              std_deviation_flow1(indices), std_deviation_flow1(indices), ...
%              'o', 'MarkerSize', 5, 'MarkerFaceColor', colors{cycle}, ...
%              'MarkerEdgeColor', colors{cycle}, 'LineWidth', 0.5,'DisplayName', sprintf('Cycle %d', cycle));
% 
%     % Fit linear model
%     mdl_pvq_off{cycle} = fitlm(average_flow1(indices), average_pressure_off(indices));
% 
%     % Calculate R-squared value
%     p_pvq_off = polyfit(average_flow1(indices), average_pressure_off(indices), 1);
%     yFit_pvq_off = polyval(p_pvq_off, average_flow1(indices));
%     yMean = mean(average_pressure_off(indices));
%     SSR = sum((yFit_pvq_off - yMean).^2);
%     SSE = sum((average_pressure_off(indices) - yFit_pvq_off).^2);
%     R2_pvq_off = SSR / (SSR + SSE);
% 
%     % Plot linear model
%     plot(mdl_pvq_off{cycle}, 'DisplayName', sprintf('Linear Fit, Cycle %d', cycle));
%     % Plot the fitted line
%     plot(average_flow1(indices), yFit_pvq_off, 'Color',colors{cycle},'Linestyle','-', 'LineWidth',1, 'DisplayName', sprintf('Fitted Line, Cycle %d', cycle));
% 
%     % Store p and R2 values
%     p_values{cycle} = p_pvq_off;
%     R2_values(cycle) = R2_pvq_off;
% 
%      % Define annotation positions based on cycle number
%     x_pos = 0.6;
%     y_pos_txt = 0.6 - (cycle - 1) * 0.1;
%     y_pos_txt1 = 0.7 - (cycle - 1) * 0.1;
% 
%     % Display R-squared value and equation of the linear fit on the plot
%     txt = sprintf('R^2 = %.4f', R2_pvq_off);
%     annotation('textbox', [x_pos, y_pos_txt, 0.01, 0.02],'String', txt, 'FitBoxToText', 'on', 'BackgroundColor', colors{cycle});
%     txt1 = sprintf('ΔP = %.4f Q (+) %.4f', p_pvq_off(1), p_pvq_off(2));
%     annotation('textbox',[x_pos, y_pos_txt1, 0.01, 0.02],  'String', txt1, 'FitBoxToText', 'on', 'BackgroundColor', colors{cycle});
% 
%     % Store handles for legend
%     legend_handles(cycle) = scatter_handles;
% end
% hold off;
% legend(legend_handles,'Location','best')
% 
% % Displaying the models and values
% for cycle = 1:3
%     disp(['Model pvq_off for cycle ', num2str(cycle)]);
%     disp(mdl_pvq_off{cycle});
%     disp(['p values for cycle ', num2str(cycle)]);
%     disp(p_values{cycle});
%     disp(['R2 value for cycle ', num2str(cycle)]);
%     disp(R2_values(cycle));
% end


ylabel ('Applied pressure (mbar)')
xlabel ('Flow rate (nL/min)')
%title('Pressure over flow rate S blue flow sensor resistance adjustment+offset')

% % Format the results as a string
% resultString = sprintf('Analysis Results:\n');
% resultString = sprintf('%sHydrodynamic Resistance (mbar/nL/min): %.4f\n', resultString,  p_pvq_off(1,1));
% resultString = sprintf('%sIntercept (mbar): %.4f\n', resultString,  p_pvq_off(1,2));
% 
% % Display the results in a pop-up window
% msgbox(resultString, 'Analysis Results');
% 


% Plot Q over DP (single cycle)
figure
errorbar(average_pressure_off, average_flow1, std_deviation_flow1, std_deviation_flow1,std_deviation_pressure1 ,std_deviation_pressure1,  'o', 'MarkerSize', 4, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'b', 'LineWidth', 0.5);
hold on

y_min =min(average_flow1)-5; 
y_max = max(average_flow1)+20;
ylim([y_min, y_max]);
x_min = min(average_pressure_off)-5;
x_max = 150;
xlim([x_min, x_max]);
% Fit a linear polynomial (degree 1) to the data
p_qvp_off = polyfit(average_pressure_off,average_flow1, 1);

% Evaluate the fitted polynomial over a range of x values
yFit_qvp_off = polyval(p_qvp_off, average_pressure_off);

mdl_qvp_off=fitlm(average_pressure_off,average_flow1)

% Plot the fitted line
plot(average_pressure_off, yFit_qvp_off, 'b-', 'LineWidth',0.5);
plot(mdl_qvp_off)

legend('Datapoints','Random Intercept', 'Location','northwest');
%title('Flow rate over applied pressure S blue capillary resistance with adjustment+offset')
%Calculate R-squared value - change to average flow (without 1 if you
%include 0 mbar data
yMean = mean(average_flow1);
SSR_off1 = sum((yFit_qvp_off - yMean).^2);
SSE_off1 = sum((average_flow1 - yFit_qvp_off).^2);
R2_qvp_off = SSR_off1 / (SSR_off1 + SSE_off1);

% Display R-squared value on the plot
txt = sprintf('R^2 = %.4f', R2_qvp_off);
annotation('textbox', [0.6,0.6,0.01,0.02],'String', txt, 'FitBoxToText', 'on', 'BackgroundColor', 'white');
txt1 = sprintf('Q = %.4f ΔP (+) %.4f', p_qvp_off);
annotation('textbox',[0.6,0.7,0.01,0.02],  'String', txt1, 'FitBoxToText', 'on', 'BackgroundColor', 'white');

% % Preallocate storage for p and R2
% p_values_qvp_off = cell(1, 3); % Store p values for each cycle
% R2_values_qvp_off = zeros(1, 3); % Store R2 values for each cycle
% 
% % Preallocate cell array to store linear model objects
% mdl_qvp_off = cell(1, 3);
% legend_handles = gobjects(1, 3); % Preallocate array for legend handles
% 
% % Plot Q over DP for each pressure step cycle
% figure;
% hold on;
% for cycle = 1:3
%     indices = (cycle - 1) * 6 + (1:6);
%     scatter_handles_qvp=errorbar(average_pressure_off(indices), average_flow1(indices),...
%              std_deviation_flow1(indices), std_deviation_flow1(indices), ...
%              std_deviation_pressure1(indices), std_deviation_pressure1(indices), ...
%              'o', 'MarkerSize', 5, 'MarkerFaceColor', colors{cycle}, ...
%              'MarkerEdgeColor', colors{cycle}, 'LineWidth', 0.5,'DisplayName', sprintf('Cycle %d', cycle));
% 
%     % Fit linear model
%     mdl_qvp_off{cycle} = fitlm(average_pressure_off(indices),average_flow1(indices));
% 
%     % Calculate R-squared value
%     p_qvp_off = polyfit(average_pressure_off(indices), average_flow1(indices),1);
%     yFit_qvp_off = polyval(p_qvp_off, average_pressure_off(indices));
%     yMean = mean(average_flow1(indices));
%     SSR = sum((yFit_qvp_off - yMean).^2);
%     SSE = sum((average_flow1(indices) - yFit_qvp_off).^2);
%     R2_qvp_off = SSR / (SSR + SSE);
% 
%     % Plot linear model
%     plot(mdl_qvp_off{cycle}, 'DisplayName', sprintf('Linear Fit, Cycle %d', cycle));
%     % Plot the fitted line
%     plot(average_pressure_off(indices), yFit_qvp_off, 'Color',colors{cycle},'Linestyle','-', 'LineWidth',1, 'DisplayName', sprintf('Fitted Line, Cycle %d', cycle));
% 
%     % Store p and R2 values
%     p_values_qvp_off{cycle} = p_qvp_off;
%     R2_values_qvp_off(cycle) = R2_qvp_off;
% 
%      % Define annotation positions based on cycle number
%     x_pos = 0.6;
%     y_pos_txt = 0.6 - (cycle - 1) * 0.1;
%     y_pos_txt1 = 0.7 - (cycle - 1) * 0.1;
% 
%     % Display R-squared value and equation of the linear fit on the plot
%     txt = sprintf('R^2 = %.4f', R2_qvp_off);
%     annotation('textbox', [x_pos, y_pos_txt, 0.01, 0.02],'String', txt, 'FitBoxToText', 'on', 'BackgroundColor', colors{cycle});
%     txt1 = sprintf('Q = %.4f ΔP (+) %.4f', p_qvp_off(1), p_qvp_off(2));
%     annotation('textbox',[x_pos, y_pos_txt1, 0.01, 0.02],  'String', txt1, 'FitBoxToText', 'on', 'BackgroundColor', colors{cycle});
% 
%     % Store handles for legend
%     legend_handles(cycle) = scatter_handles_qvp;
% end
% hold off;
% legend(legend_handles,'Location','best')
% 
% % Displaying the models and values
% for cycle = 1:3
%     disp(['Model qvp_off for cycle ', num2str(cycle)]);
%     disp(mdl_qvp_off{cycle});
%     disp(['p values for cycle ', num2str(cycle)]);
%     disp(p_values_qvp_off{cycle});
%     disp(['R2 value for cycle ', num2str(cycle)]);
%     disp(R2_values_qvp_off(cycle));
% end
% 
% 
ylabel ('Flow rate (nL/min)')
xlabel ('Applied pressure (mbar)')
title('Q over ΔP BSO 4434 2.5mm 37C DMEM N75 ADH R2 WSY R9 + offset')

%% Plot r(t)
t_overnight=t1(113705:463514);  % change
hours_t_overnight=t_overnight/3600;
f_overnight=f(113705:463514); % change

p_ON=106.6*ones(size(hours_t_overnight)); % change

Qfo = filters_short(f_overnight, t_overnight,120);
%R0 =116.75./Qfo; % 80 mbar =60 mmHg
R0 =106.6./Qfo;%f_overnight; % 80 mbar =60 mmHg

QR = filters_short(R0, t_overnight,120); % filtered data flow sensurion _S

%Qfo = filters_short(f_overnight, t_overnight,600);

figure

% Plot R0 and QR on the left y-axis
subplot (2,1,2)

plot(hours_t_overnight, R0, 'Color', [0 0 0 0.05],'LineStyle', '-', 'LineWidth', 0.3);
hold on
plot(hours_t_overnight, QR, 'k-', 'LineWidth', 0.5);

% Set labels for the left y-axis
ylabel('R (mbar/nL/min)');

% Set the ylim for the left axis %resistance
y_min = 0;
y_max = max(QR)+2;
ylim([y_min, y_max]);

xlabel('Perfusion time (hrs)');
% Set common properties
sgtitle('Resistance change over time of BSO 4434 2.5mm 37C DMEM N75 ADH R2 WSY R9');

% Plot f_overnight and Qfo on the right y-axis
subplot (2,1,1)
% Plot p on the second y-axis
yyaxis left
plot(hours_t_overnight, p_ON, 'b--', 'LineWidth', 3);
% Set labels for the second y-axis
ylabel('Applied pressure (mbar)');
% Set the ylim for the second y-axis - pressure
% y_min_p = 0;
% y_max_p = 150; % Adjust the limits as needed
% ylim([y_min_p, y_max_p]);


yyaxis right

% Add additional plots to the right y-axis if needed
plot(hours_t_overnight, f_overnight, 'Color', [1 0 0 0.01],'LineStyle', '--', 'LineWidth', 1);
hold on
plot(hours_t_overnight, Qfo, 'r--', 'LineWidth', 3);

% Set labels for the right y-axis if needed
ylabel('Flow rate (nL/min)');


% % Set the x-axis limits for the right y-axis % flow
yyaxis right
y_min = 0;
y_max = 1500;
ylim([y_min, y_max]);


xlabel('Perfusion time (hrs)');

 %legend('Non filtered', 'Filtered', 'Flow rate');
% legend('WS', 'BS','SLG64','Location','eastoutside');

%% Relative r(t) 
hours_t_overnight_r=hours_t_overnight(1:end);
f_overnight_r=f_overnight(1:end);
Qfo_r=Qfo(1:end);
R0r = R0(1:end)./R0(1,1); 
QRr = filters_short(R0r, t_overnight,200); % filtered data flow sensurion _S
y_con=ones(size(hours_t_overnight_r));
 
figure
 yyaxis left
 %plot (hours_t_overnight_r, R0r,'b--', 'LineWidth',1);
y_min = 0.1;
y_max = 5;
ylim([y_min,y_max]);
 hold on
plot (hours_t_overnight_r, QRr,'b--','LineWidth',2);
plot (hours_t_overnight_r, y_con,'g--','LineWidth',3);
ylabel('Relative resistance (-)');
yyaxis right
%plot(hours_t_overnight_r, f_overnight_r,'Color', [1 0 0 0.05],'LineStyle', '--', 'LineWidth', 1);
plot (hours_t_overnight_r, Qfo_r,'r--','LineWidth',3);
y_min =0;
y_max =1500;
ylim([y_min,y_max]);
grid on

title('Relative change of Resistance over time of WSY 4434 2.5mm 37C DMEM N75 ADH R2 WSY R9');
xlabel('Perfusion time (hrs)');
ylabel('Flow rate (nL/min)');
legend('Filtered Relative resistance (-)','R-Relative=1','Flow rate','Filtered flow rate (nL/min)','Location','best'); %'Relative Resistance (-)'


%% Store variables
% Choose a folder interactively
folderPath = uigetdir('C:\', 'Select a folder to save your MAT file');

% Check if the user canceled the folder selection
if folderPath == 0
    disp('Folder selection canceled. Exiting...');
    return;
end
% Specify the file name and extension (e.g., 'myVariables.mat')
fileName = 'DP_F_R_STD_ WSY 4434 2.5mm 37C DMEM N75 ADH R2-R9.mat';

% Create the full file path
fullFilePath = fullfile(folderPath, fileName);

% Save the variables to the MAT file
save(fullFilePath, 'average_flow1','std_deviation_flow1', 'average_pressure1','average_pressure_off','std_deviation_pressure1','R','std_R');

disp(['Variables saved to: ' fullFilePath]);
%% Store variables
% Choose a folder interactively
folderPath = uigetdir('C:\', 'Select a folder to save your MAT file');

% Check if the user canceled the folder selection
if folderPath == 0
    disp('Folder selection canceled. Exiting...');
    return;
end
% Specify the file name and extension (e.g., 'myVariables.mat')
fileName = 'slopes - WSY 4434 2.5mm 37C DMEM N75 ADH R2-R9.mat';

% Create the full file path
fullFilePath = fullfile(folderPath, fileName);

% Save the variables to the MAT file
save(fullFilePath, 'slope_flowf','slope_flowQf', 'slope_mdl','slope_mdl_Qf');

disp(['Variables saved to: ' fullFilePath]);