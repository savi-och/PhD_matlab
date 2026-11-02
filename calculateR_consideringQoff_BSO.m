folderPath = 'C:\Users\scharalambous\OneDrive - Imperial College London\PhD folder\Experimental data\EXP24N49 - 4434 melanoma microbead_resistance\P1\Cumulative';  % Replace with your actual folder path

% Define the common beginning of file names or use an appropriate pattern
commonBeginning = 'DP_F_R_STD_';  % Replace with your pattern

% Get a list of all .mat files in the folder
matFiles = dir(fullfile(folderPath, [commonBeginning, '*.mat']));

fileName = fullfile(folderPath, matFiles.name);

% Load the .mat file
s = load(fileName);

% Access the main matrix variable (replace with your actual variable name)
flow_without_offset = s.average_flow1;
pressure_with_offset=s.average_pressure_off;
flow_with_offset=s.average_flow1;


% % Perform your custom calculation
s.R_cons_offset = pressure_with_offset ./flow_with_offset;  % Example math

%s=rmfield(s,'R_cons_offset') %deletes column



% Save it back into the .mat file (overwrite the original variable)
save(fileName, '-struct', 's');
%%
folderPath = 'C:\Users\scharalambous\OneDrive - Imperial College London\PhD folder\Experimental data\EXP24N49 - 4434 melanoma microbead_resistance\P1\Cumulative'
commonBeginning = 'DP_F_R_STD_';

% Get all matching .mat files
matFiles = dir(fullfile(folderPath, [commonBeginning, '*.mat']));
fileNames = {matFiles.name};

% 🟢 Open popup to select which files to process
[selectedIndices, ok] = listdlg(...
    'PromptString', 'Select the files you want to process:', ...
    'SelectionMode', 'multiple', ...
    'ListSize', [400, 400], ...
    'ListString', fileNames);

if ~ok
    disp('❌ No files selected. Script canceled.');
    return;
end

% % Display indexed list of files
% fprintf('Available .mat files:\n');
% for i = 1:length(matFiles)
%     fprintf('%d: %s\n', i, matFiles(i).name);
% end
% 
% % Ask user for indices to process
% userInput = input('\nEnter the indices of files you want to process (e.g., [1 3 5]): ');
% 
% % Validate input
% if isempty(userInput) || ~isnumeric(userInput)
%     error('Invalid input. Please enter a vector of numeric indices like [1 3 5].');
% end

% Ask for the offset value to subtract
offset = input('\nEnter the flow offset value to subtract (e.g., 21): ');
if isempty(offset) || ~isnumeric(offset)
    error('Invalid offset. Please enter a numeric value.');
end

% Loop over selected indices
for idx = selectedIndices %userInput
    if idx > length(matFiles)
        warning('Index %d exceeds the number of files. Skipping...', idx);
        continue;
    end

    fileName = fullfile(folderPath, matFiles(idx).name);

    % Load the .mat file
    s = load(fileName);

    % Your calculations or updates
    flow_without_offset = s.average_flow1;
    pressure_with_offset = s.average_pressure_off;
    flow_with_offset = s.average_flow1-offset; %!!!!! add offset

    %s.R_cons_offset = pressure_with_offset ./ flow_with_offset;
    s.average_flow1_off = flow_with_offset;
    % % Perform your custom calculation
    s.R_cons_offset = pressure_with_offset ./flow_with_offset; 

    fullPath = fullfile(folderPath, fileName);
if length(fullPath) > 240
    warning('File path is too long: %d characters', length(fullPath));
end

   % s=rmfield(s,'R_cons_offset') %deletes column

    % Save the updated struct back
    save(fileName, '-struct', 's');

    fprintf('✅ Processed: %s\n', matFiles(idx).name);
end


