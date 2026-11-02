%function plotResistanceVsPressure1(folderPath, commonBeginning)
% Function to load explant resistance data and plot regression lines with scatter
% with optional data exclusion and safe checks for empty condition data.
%
% USAGE:
%   plotResistanceVsPressure('C:\\Path\\To\\Data', 'DP_F_R_STD_');

close all; clc; clear all;

folderPath = 'C:\Users\scharalambous\OneDrive - Imperial College London\PhD folder\Thesis writing\2025\Chapter 1\Hydraulic resistance_R_data analysis\4434\ePERF constriction';  % Replace with your actual folder path

% Define the common beginning of file names or use an appropriate pattern
commonBeginning = 'DP_F_R_STD_';  % Replace with your pattern


% 1) Get all matching .mat files
matFiles = dir(fullfile(folderPath, [commonBeginning, '*.mat']));
fileNames = {matFiles.name}';

% 2) Prompt Condition 1 selection
[cond1InputNB, ok1] = listdlg( ...
    'PromptString','Select files for CONDITION 1 (NB)', ...
    'SelectionMode','multiple', ...
    'ListString', fileNames, ...
    'ListSize',[400 400]);
if ~ok1
    cond1InputNB = [];  % User clicked 'Cancel' or closed dialog — treat as no selection
    fprintf('No files selected for Condition 1 (NB).\n');
end

% 3) Prompt Condition 2 selection
[cond2InputEBV1, ok2] = listdlg( ...
    'PromptString','Select files for CONDITION 2 (EB)', ...
    'SelectionMode','multiple', ...
    'ListString', fileNames, ...
    'ListSize',[400 400]);
if ~ok2
    cond2InputEBV1 = [];  % User clicked 'Cancel' or closed dialog — treat as no selection
    fprintf('No files selected for Condition 2 (EBV1).\n');
end

% 4) The rest become condition 3 (EBV2)
allAvailable = 1:numel(matFiles);
allSelected = unique([cond1InputNB, cond2InputEBV1]);
cond3InputEBV2 = setdiff(allAvailable, allSelected);

fprintf('Condition 1 (NB):\n');   disp({matFiles(cond1InputNB).name});
fprintf('Condition 2 (EBV1):\n'); disp({matFiles(cond2InputEBV1).name});
fprintf('Condition 3 (EBV2):\n'); disp({matFiles(cond3InputEBV2).name});


% 5) OPTIONAL EXCLUSION STEP
answer = questdlg('Exclude any files from these conditions?', 'Exclude Data?', 'Yes','No','No');
switch answer
    case 'Yes'
        % Combine all selected
        combinedSelected = [cond1InputNB, cond2InputEBV1, cond3InputEBV2];
        combinedNames = fileNames(combinedSelected);

        [exclIdx, okExclude] = listdlg( ...
            'PromptString', 'Pick any files you want to EXCLUDE', ...
            'SelectionMode', 'multiple', ...
            'ListString', combinedNames, ...
            'ListSize',[400 400]);

        if okExclude
            filesToExclude = combinedSelected(exclIdx);
            fprintf('\nExcluding these files:\n'); disp({matFiles(filesToExclude).name});
            % Remove them from each condition
            cond1InputNB   = setdiff(cond1InputNB,   filesToExclude);
            cond2InputEBV1 = setdiff(cond2InputEBV1, filesToExclude);
            cond3InputEBV2 = setdiff(cond3InputEBV2, filesToExclude);
        end
    case 'No'
        fprintf('No files excluded.\n');
end
%%
% 6) Initialize data storage
pressure_data_cond1   = [];
resistance_data_cond1 = [];
origin_files_cond1    = [];

pressure_data_cond2   = [];
resistance_data_cond2 = [];
origin_files_cond2    = [];

pressure_data_cond3   = [];
resistance_data_cond3 = [];
origin_files_cond3    = [];

% 7) Load and filter data
for idx = 1:numel(allAvailable)
    fileIdx = allAvailable(idx);
    fileName = fullfile(folderPath, matFiles(fileIdx).name);
    load(fileName);

    % Basic filter
    v3 = average_pressure_off(:);
    v5 = R_cons_offset(:);
    v4 = R (:);
    v3_mmHg = v3 / 1.33;
    % Choose which filters based on iPERF or ePERF

    valid_indices = v3_mmHg >= 9 & v5 > 0 & v5 < 70; % you can adjust these thresholds ePERF 
    % valid_indices = v3_mmHg >= 9 & v4 > 0 & v4 < 70; % you can adjust these thresholds

    if ~any(valid_indices), continue; end

    % Convert from mbar -> mmHg if needed
    P = v3_mmHg(valid_indices);
    Rvals = v5(valid_indices) / 1.33; %!!! ALTER between iPERF and ePERF
    logR = log(Rvals);

    % % Collect into the correct condition
    % if ismember(fileIdx, cond1InputNB)
    %     pressure_data_cond1     = [pressure_data_cond1;     P];
    %     resistance_data_cond1   = [resistance_data_cond1;   Rvals];
    %     origin_files_cond1      = [origin_files_cond1;      repmat({matFiles(fileIdx).name}, numel(P), 1)];
    % 
    % elseif ismember(fileIdx, cond2InputEBV1)
    %     pressure_data_cond2     = [pressure_data_cond2;     P];
    %     resistance_data_cond2   = [resistance_data_cond2;   Rvals];
    %     origin_files_cond2      = [origin_files_cond2;      repmat({matFiles(fileIdx).name}, numel(P), 1)];
    % 
    % elseif ismember(fileIdx, cond3InputEBV2)
    %     pressure_data_cond3     = [pressure_data_cond3;     P];
    %     resistance_data_cond3   = [resistance_data_cond3;   Rvals];
    %     origin_files_cond3      = [origin_files_cond3;      repmat({matFiles(fileIdx).name}, numel(P), 1)];
    % end

    % LOG: Collect into the correct condition
    if ismember(fileIdx, cond1InputNB)
        pressure_data_cond1     = [pressure_data_cond1;     P];
        resistance_data_cond1   = [resistance_data_cond1;   logR];
        origin_files_cond1      = [origin_files_cond1;      repmat({matFiles(fileIdx).name}, numel(P), 1)];

    elseif ismember(fileIdx, cond2InputEBV1)
        pressure_data_cond2     = [pressure_data_cond2;     P];
        resistance_data_cond2   = [resistance_data_cond2;   logR];
        origin_files_cond2      = [origin_files_cond2;      repmat({matFiles(fileIdx).name}, numel(P), 1)];

    elseif ismember(fileIdx, cond3InputEBV2)
        pressure_data_cond3     = [pressure_data_cond3;     P];
        resistance_data_cond3   = [resistance_data_cond3;   logR];
        origin_files_cond3      = [origin_files_cond3;      repmat({matFiles(fileIdx).name}, numel(P), 1)];
    end
end

% 8) Create tables
T1 = table(resistance_data_cond1, pressure_data_cond1, origin_files_cond1, ...
    'VariableNames', {'Resistance','Pressure','File'});
T2 = table(resistance_data_cond2, pressure_data_cond2, origin_files_cond2, ...
    'VariableNames', {'Resistance','Pressure','File'});
T3 = table(resistance_data_cond3, pressure_data_cond3, origin_files_cond3, ...
    'VariableNames', {'Resistance','Pressure','File'});
%% -----------------------------------------------------------------
%% 9)  ===  MIXED-EFFECTS ANALYSIS  =================================
%% -----------------------------------------------------------------
% (keep everything above unchanged)

% A. -----  Combine the three condition tables ----------------------
T1.Condition = repmat("NB"   ,height(T1),1);
T2.Condition = repmat("EBV1" ,height(T2),1);
T3.Condition = repmat("EBV2" ,height(T3),1);

T   = [T1; T2; T3];
T.Properties.VariableNames{'File'} = 'ExplantID';   % clearer name

% Make types explicit
T.Condition = categorical(T.Condition, ["NB" "EBV1" "EBV2"]);
T.ExplantID = categorical(T.ExplantID);

% Centre Pressure (keeps intercept interpretable)
T.Pc  = T.Pressure - mean(T.Pressure);

% Make sure Condition only contains categories that are actually present
T.Condition = removecats(T.Condition);     % <--- add this line


figure;  
hold on
gscatter(T.Pressure, T.Resistance, T.Condition, ...
         [0 0 1; 1 0 1; 0.466 0.674 0.188], '.', 15);
xlabel('\DeltaP (mmHg)'); 
ylabel('R (mmHg·nL/min)'); 
ylabel('logR (mmHg·nL/min)');
title('Resistance vs \DeltaP  (raw data)');
grid on
legend({'NB','EBV1','EBV2'},'Location','northwest');

%% -----------------------------------------------------------------
%% B.   Fit two candidate mixed-effects models
%% -----------------------------------------------------------------

% 1) random-intercept only
mdl_lin = fitlme(T, ...
    'Resistance ~ Pc*Condition + (1|ExplantID)');

% 2) random-intercept  + random-slope
mdl_rnd = fitlme(T, ...
    'Resistance ~ Pc*Condition + (Pc|ExplantID)');


%% C.   Compare the two models  (likelihood-ratio + information criteria)


cmpTbl = compare(mdl_lin, mdl_rnd);   % returns a table-like object
disp(' ')
disp('---  Intercept-only  vs  Random-slope  --------------------------------')
disp(cmpTbl)
disp('-----------------------------------------------------------------------')

% Decision rule: keep random-slope if LR-test p < 0.05
useRndSlope = cmpTbl.pValue(2) < 0.05;

if useRndSlope
    fprintf('✓  Random slope improves the model (p = %.5f)\n', cmpTbl.pValue(2));
    mdl = mdl_rnd;
else
    fprintf('✓  Random slope NOT needed (p = %.5f) – using intercept-only model\n', cmpTbl.pValue(2));
    mdl = mdl_lin;
end

%%
% D. -----  Overall test: do slopes differ? -------------------------
anovaTbl = anova(mdl,'DFMethod','satterthwaite');
fprintf('\nCondition × Pressure interaction p-value  = %.4f\n', ...
        anovaTbl.pValue( contains(anovaTbl.Term,'Condition:Pc') ));

%% E. -----  Pair-wise slope contrasts -------------------------------
coefNames = mdl.CoefficientNames;
idx_EBV1  = find(contains(coefNames,'Condition_EBV1:Pc'));
idx_EBV2  = find(contains(coefNames,'Condition_EBV2:Pc'));
nCoef     = numel(coefNames);

% --- NB  vs  EBV1 ---------------------------------------------------
C_NB_EBV1                  = zeros(1,nCoef);
C_NB_EBV1(idx_EBV1)        = 1;                 % tests βPc:Condition_EBV1 = 0
p_NB_EBV1  = coefTest(mdl , C_NB_EBV1);        % returns the p-value only

% --- NB  vs  EBV2 ---------------------------------------------------
C_NB_EBV2                  = zeros(1,nCoef);
C_NB_EBV2(idx_EBV2)        = 1;                 % tests βPc:Condition_EBV2 = 0
p_NB_EBV2  = coefTest(mdl , C_NB_EBV2);

% --- EBV1  vs  EBV2  (difference of the two interaction terms) -----
C_EBV1_EBV2                = zeros(1,nCoef);
C_EBV1_EBV2(idx_EBV2)      =  1;                % +(EBV2 − NB)
C_EBV1_EBV2(idx_EBV1)      = -1;                % −(EBV1 − NB)
p_EBV1_EBV2 = coefTest(mdl , C_EBV1_EBV2);

% F. -----  Report --------------------------------------------------
fprintf('\nPair-wise slope p-values:\n');
fprintf('  NB   vs EBV1 : %6.4f\n', p_NB_EBV1);
fprintf('  NB   vs EBV2 : %6.4f\n', p_NB_EBV2);
fprintf('  EBV1 vs EBV2 : %6.4f\n', p_EBV1_EBV2);

%% ---------------------------------------------------------------
%%  G.  Report fitted slopes for NB, EBV1, EBV2
%% ---------------------------------------------------------------
% 1) grab fixed-effect estimates and their covariance matrix
% ---- grab what we need --------------------------------------------
coefT  = mdl.Coefficients;           % table with Estimate, SE, DF, …
names  = coefT.Name;               % same order
covB   = mdl.CoefficientCovariance;  % full Var–Cov matrix of β

% ---- locate the relevant columns ----------------------------------
idxPc = strcmp(names,'Pc');
idxE1 = strcmp(names,'Condition_EBV1:Pc');
idxE2 = strcmp(names,'Condition_EBV2:Pc');

% ---- build contrast vectors ---------------------------------------
L_NB   = zeros(1,numel(names));  L_NB(idxPc)  = 1;
L_EBV1 = L_NB;                   L_EBV1(idxE1)= 1;
L_EBV2 = L_NB;                   L_EBV2(idxE2)= 1;

% ---- helper to get estimate, SE, 95 % CI ---------------------------
dfSlope = coefT.DF(idxPc);                  % same DF for all slope terms
getSlope = @(L) deal( ...
        L*coefT.Estimate , ...              % point estimate
        sqrt(L*covB*L') , ...               % SE
        tinv([0.025 0.975], dfSlope) ...    % t-quantile
           .* sqrt(L*covB*L') + L*coefT.Estimate );

% ---- compute slopes -----------------------------------------------
[sNB , seNB , ciNB ] = getSlope(L_NB);
[sE1 , seE1 , ciE1 ] = getSlope(L_EBV1);
[sE2 , seE2 , ciE2 ] = getSlope(L_EBV2);

% ---- print --------------------------------------------------------
fprintf('\nEstimated slopes (ΔR per 1 mmHg ΔP)\n');
fprintf('  NB   : %.4f  (SE %.4f, 95%% CI [%.4f , %.4f])\n', sNB , seNB , ciNB );
fprintf('  EBV1 : %.4f  (SE %.4f, 95%% CI [%.4f , %.4f])\n', sE1 , seE1 , ciE1 );
fprintf('  EBV2 : %.4f  (SE %.4f, 95%% CI [%.4f , %.4f])\n', sE2 , seE2 , ciE2 );

% beta = fixedEffects(mdl);           % column-vector of estimates % gives betas (population-level parameters)
% disp (FE)
% names  = mdl.CoefficientNames;            % same order as ‘beta’
% covB   = mdl.CoefficientCovariance;       % full covariance matrix

%% F. -----  Quadratic (non-linearity) check -------------------------

T.Pc2 = T.Pc.^2;                         % add squared term

% --- choose the random-effects part already selected in Step C -------
if useRndSlope
    randForm = '(Pc|ExplantID)';         % random intercept + slope
else
    randForm = '(1|ExplantID)';          % random intercept only
end

% --- fixed-effect formulas -----------------------------------------
fixed_lin   = 'Resistance ~ Pc*Condition';
fixed_quad  = 'Resistance ~ (Pc + Pc2)*Condition';

form_lin    = [fixed_lin  ' + ' randForm];
form_quad   = [fixed_quad ' + ' randForm];

% --- fit both with ML ----------------------------------------------
mdl_linML   = fitlme(T, form_lin ,  'FitMethod','ML');
mdl_quadML  = fitlme(T, form_quad,  'FitMethod','ML');

% --- compare -------------------------------------------------------
cmpQuad = compare(mdl_linML, mdl_quadML);      % LRT, AIC, BIC
disp(' ')
disp('Quadratic vs linear (same random structure, ML fit)')
disp(cmpQuad)

if cmpQuad.pValue(2) < 0.05
    fprintf('✓  Keep quadratic terms (p = %.4f)\n', cmpQuad.pValue(2));
    bestFormula = form_quad;
else
    fprintf('✓  Linear form adequate (p = %.4f)\n', cmpQuad.pValue(2));
    bestFormula = form_lin;
end

% --- refit the chosen model with REML for final inference ----------
mdl_final = fitlme(T, bestFormula);      % REML is default




%% 10)  ===  PLOTTING  =============================================
%%  Build PredTbl in one shot (no row-length surprises) --> this is to build confidence intervals
%% --------------------------------------------------------------
Pgrid   = (0:5:ceil(max(T.Pressure)))';            % e.g. 0 5 10 … 80  → n×1 
n       = numel(Pgrid);

% three-condition column, n rows each
condVec = repelem(["NB" "EBV1" "EBV2"]', n);       % 3n × 1 string array
condCat = categorical(condVec, ["NB" "EBV1" "EBV2"]);

% pressure columns replicated for the three blocks
pressVec = repmat(Pgrid , 3, 1);                   % 3n × 1 numeric
PcVec    = pressVec - mean(T.Pressure);            % centred pressure
% pick one existing explant label (first in your data)
refID   = T.ExplantID(1);
expVec  = repmat(refID , numel(Pgrid)*3 , 1);   % 3n × 1 categorical

PredTbl = table( PcVec , condCat , expVec , ...
                 'VariableNames', {'Pc','Condition','ExplantID'});


% PredTbl  = table( pressVec      , ...
%                   condCat       , ...
%                   PcVec         , ...
%                   'VariableNames', {'Pressure', 'Condition', 'Pc'});

% add squared term only if the final model kept it
if any(strcmp(mdl_final.CoefficientNames,'Pc2'))
    PredTbl.Pc2 = PredTbl.Pc.^2;
end


[ypred, yCI] = predict(mdl_final, PredTbl, 'Conditional',false); % should not take into account the Explant ID

% plot raw scatter --------------------------------------------------
figure;  hold on
gscatter(T.Pressure , T.Resistance , T.Condition , ...
         [0 0 1; 1 0 1; 0.466 0.674 0.188], '.', 15);
xlabel('\DeltaP (mmHg)'); ylabel('R (mmHg·nL/min)');
title('Resistance vs \DeltaP   (mixed-effects fit)');
grid on

% plot fitted lines & 95 % CI --------------------------------------
conds   = categories(T.Condition);
colRGB  = [0 0 1; 1 0 1; 0.466 0.674 0.188];
for k = 1:numel(conds)
    idx = PredTbl.Condition == conds{k};
    plot(Pgrid , ypred(idx) , 'Color',colRGB(k,:), 'LineWidth',2);
    % confidence band
    fill([Pgrid; flipud(Pgrid)], ...
         [yCI(idx,1); flipud(yCI(idx,2))], ...
         colRGB(k,:), 'FaceAlpha',0.15, 'EdgeColor','none');
end
legend({'NB','EBV1','EBV2','NB fit','NB CIs','EBV1 fit','EBv1 CIs','EBV2 fit','EBv2 CIs'},'Location','northwest');


%  Extra annotations: slopes, pair-wise p, overall slope p, Pearson r

ax = gca;      % current axes

% --- 1. slopes ------------------------------------------------------
coefT = mdl_final.Coefficients;
names = coefT.Name;
bPc   = coefT.Estimate(strcmp(names,'Pc'));

bE1   = 0;  if any(strcmp(names,'Condition_EBV1:Pc')), bE1 = ...
              coefT.Estimate(strcmp(names,'Condition_EBV1:Pc')); end
bE2   = 0;  if any(strcmp(names,'Condition_EBV2:Pc')), bE2 = ...
              coefT.Estimate(strcmp(names,'Condition_EBV2:Pc')); end

slope.NB   = bPc;
slope.EBV1 = bPc + bE1;
slope.EBV2 = bPc + bE2;

fprintf('\nFitted slopes  (ΔR / 1 mmHg ΔP)\n');
fprintf('  NB   : %.4f\n', slope.NB);
fprintf('  EBV1 : %.4f\n', slope.EBV1);
fprintf('  EBV2 : %.4f\n', slope.EBV2);

% put them on the plot
text(ax, 0.02, 0.94, sprintf('\\itSlope\\rm NB   = %.3f', slope.NB),   ...
     'Units','normalized','Color',[0 0 1]);
text(ax, 0.02, 0.90, sprintf('\\itSlope\\rm EBV1 = %.3f', slope.EBV1), ...
     'Units','normalized','Color',[1 0 1]);
text(ax, 0.02, 0.86, sprintf('\\itSlope\\rm EBV2 = %.3f', slope.EBV2), ...
     'Units','normalized','Color',[0.466 0.674 0.188]);

% --- 2. pair-wise slope p-values (already computed earlier) ---------
text(ax, 0.50, 0.94, sprintf('p_{NB–EBV1} = %.3g', p_NB_EBV1), ...
     'Units','normalized','Color','k');
text(ax, 0.50, 0.90, sprintf('p_{NB–EBV2} = %.3g', p_NB_EBV2), ...
     'Units','normalized','Color','k');
text(ax, 0.50, 0.86, sprintf('p_{EBV1–EBV2} = %.3g', p_EBV1_EBV2), ...
     'Units','normalized','Color','k');

% --- 3. overall slope p-value (Pc term) ----------------------------
p_Pc = coefT.pValue(strcmp(names,'Pc'));
text(ax, 0.50, 0.81, sprintf('Overall slope p = %.3g', p_Pc), ...
     'Units','normalized','Color','k');

% --- 4. Pearson r (descriptive only) -------------------------------
conds = categories(T.Condition);
colors = {[0 0 1],[1 0 1],[0.466 0.674 0.188]};
rText  = cell(numel(conds),1);

for k = 1:numel(conds)
    idx  = T.Condition==conds{k};
    r    = corr(T.Pressure(idx), T.Resistance(idx),'Type','Pearson');
    rText{k} = sprintf('%s: r = %.3f', conds{k}, r);
    % annotate right margin
    text(ax, 0.80, 0.94-0.04*(k-1), rText{k}, ...
         'Units','normalized','Color',colors{k});
end
figure
plotResiduals(mdl_final,'fitted')

%% Plot without 0 mmHg

%% --------------------------------------------------------------
Pgrid   = (min(T.Pressure):5:ceil(max(T.Pressure)))';            % e.g. 0 5 10 … 80  → n×1 
n       = numel(Pgrid);

% three-condition column, n rows each
condVec = repelem(["NB" "EBV1" "EBV2"]', n);       % 3n × 1 string array
condCat = categorical(condVec, ["NB" "EBV1" "EBV2"]);

% pressure columns replicated for the three blocks
pressVec = repmat(Pgrid , 3, 1);                   % 3n × 1 numeric
PcVec    = pressVec - mean(T.Pressure);            % centred pressure
% pick one existing explant label (first in your data)
refID   = T.ExplantID(1);
expVec  = repmat(refID , numel(Pgrid)*3 , 1);   % 3n × 1 categorical

PredTbl = table( PcVec , condCat , expVec , ...
                 'VariableNames', {'Pc','Condition','ExplantID'});


% PredTbl  = table( pressVec      , ...
%                   condCat       , ...
%                   PcVec         , ...
%                   'VariableNames', {'Pressure', 'Condition', 'Pc'});

% add squared term only if the final model kept it
if any(strcmp(mdl_final.CoefficientNames,'Pc2'))
    PredTbl.Pc2 = PredTbl.Pc.^2;
end


[ypred, yCI] = predict(mdl_final, PredTbl, 'Conditional',false); % should not take into account the Explant ID

% plot raw scatter --------------------------------------------------
figure;  hold on
gscatter(T.Pressure , T.Resistance , T.Condition , ...
         [0 0 1; 1 0 1; 0.466 0.674 0.188], '.', 15);
xlabel('\DeltaP (mmHg)'); ylabel('R (mmHg·nL/min)');
title('Resistance vs \DeltaP   (mixed-effects fit)');
grid on

% plot fitted lines & 95 % CI --------------------------------------
conds   = categories(T.Condition);
colRGB  = [0 0 1; 1 0 1; 0.466 0.674 0.188];
for k = 1:numel(conds)
    idx = PredTbl.Condition == conds{k};
    plot(Pgrid , ypred(idx) , 'Color',colRGB(k,:), 'LineWidth',2);
    % confidence band
    fill([Pgrid; flipud(Pgrid)], ...
         [yCI(idx,1); flipud(yCI(idx,2))], ...
         colRGB(k,:), 'FaceAlpha',0.15, 'EdgeColor','none');
end
legend({'NB','EBV1','EBV2','NB fit','NB CIs','EBV1 fit','EBv1 CIs','EBV2 fit','EBv2 CIs'},'Location','northwest');


%  Extra annotations: slopes, pair-wise p, overall slope p, Pearson r

ax = gca;      % current axes

% --- 1. slopes ------------------------------------------------------
coefT = mdl_final.Coefficients;
names = coefT.Name;
bPc   = coefT.Estimate(strcmp(names,'Pc'));

bE1   = 0;  if any(strcmp(names,'Condition_EBV1:Pc')), bE1 = ...
              coefT.Estimate(strcmp(names,'Condition_EBV1:Pc')); end
bE2   = 0;  if any(strcmp(names,'Condition_EBV2:Pc')), bE2 = ...
              coefT.Estimate(strcmp(names,'Condition_EBV2:Pc')); end

slope.NB   = bPc;
slope.EBV1 = bPc + bE1;
slope.EBV2 = bPc + bE2;

fprintf('\nFitted slopes  (ΔR / 1 mmHg ΔP)\n');
fprintf('  NB   : %.4f\n', slope.NB);
fprintf('  EBV1 : %.4f\n', slope.EBV1);
fprintf('  EBV2 : %.4f\n', slope.EBV2);

% put them on the plot
text(ax, 0.02, 0.94, sprintf('\\itSlope\\rm NB   = %.3f', slope.NB),   ...
     'Units','normalized','Color',[0 0 1]);
text(ax, 0.02, 0.90, sprintf('\\itSlope\\rm EBV1 = %.3f', slope.EBV1), ...
     'Units','normalized','Color',[1 0 1]);
text(ax, 0.02, 0.86, sprintf('\\itSlope\\rm EBV2 = %.3f', slope.EBV2), ...
     'Units','normalized','Color',[0.466 0.674 0.188]);

% --- 2. pair-wise slope p-values (already computed earlier) ---------
text(ax, 0.50, 0.94, sprintf('p_{NB–EBV1} = %.3g', p_NB_EBV1), ...
     'Units','normalized','Color','k');
text(ax, 0.50, 0.90, sprintf('p_{NB–EBV2} = %.3g', p_NB_EBV2), ...
     'Units','normalized','Color','k');
text(ax, 0.50, 0.86, sprintf('p_{EBV1–EBV2} = %.3g', p_EBV1_EBV2), ...
     'Units','normalized','Color','k');

% --- 3. overall slope p-value (Pc term) ----------------------------
p_Pc = coefT.pValue(strcmp(names,'Pc'));
text(ax, 0.50, 0.81, sprintf('Overall slope p = %.3g', p_Pc), ...
     'Units','normalized','Color','k');

% --- 4. Pearson r (descriptive only) -------------------------------
conds = categories(T.Condition);
colors = {[0 0 1],[1 0 1],[0.466 0.674 0.188]};
rText  = cell(numel(conds),1);

for k = 1:numel(conds)
    idx  = T.Condition==conds{k};
    r    = corr(T.Pressure(idx), T.Resistance(idx),'Type','Pearson');
    rText{k} = sprintf('%s: r = %.3f', conds{k}, r);
    % annotate right margin
    text(ax, 0.80, 0.94-0.04*(k-1), rText{k}, ...
         'Units','normalized','Color',colors{k});
end