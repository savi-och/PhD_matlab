%% ========================================================================
% *READ ME -- RUN  plotResistanceVsPressure2 (first three sections)!!!!* 
% 
% ePERF CONSTRICTION -- THREE CONDITIONS: NB vs EBV1 vs EBV2
%  Small-n descriptive analysis (approx 6/7/5 explants).
%
%  DIFFERENCES FROM THE TWO-CONDITION SCRIPT
%   - Condition has three levels, so there is no single "interaction"
%     coefficient. The omnibus question ("do the slopes differ at all?")
%     is a joint 2-df test, obtained from anova(), not from a coefficient.
%   - Coefficients are stored as ARRAYS indexed by condition rather than as
%     scalars b_cnd / b_int.
%   - Two-sample tests are replaced by Kruskal-Wallis plus per-condition
%     descriptives. At n = 5-7 per group these are DESCRIPTIVE.
%   - The paired-within-experiment analysis is dropped: pairs become
%     triples and most sessions will not contain all three conditions.
%   - Random-effects structure has a convergence fallback chain.
%
%  READ THE RESULTS AS DESCRIPTIVE. With 5-7 explants per condition an
%  omnibus null is uninformative about whether a difference exists.
%  ========================================================================

%% ---- 0. CONSTANTS AND SETUP -------------------------------------------

Q_LOD    = 4.5;    % nL/min. 3 x repeatability (1.5 nL/min), SLG-0075 Precision.
Q_SAT    = 5500;   % nL/min. Sensor output limit.
W_FLOOR  = 0.01;   % minimum relative SD used for weighting
MIN_STEPS= 3;      % minimum pressure steps for a per-explant slope
MIN_SPAN = 30;     % mmHg, minimum pressure range for a per-explant slope
P1 = 20;  P2 = 80; % endpoints for fold-change reporting
SPAN = P2 - P1;

logName = sprintf('resistance_3cond_%s.txt', datestr(now,'yyyymmdd_HHMM'));
diary(logName); diary on

fprintf('========================================================\n');
fprintf('ePERF CONSTRICTION -- THREE-CONDITION ANALYSIS\n');
fprintf('Run: %s\n', datestr(now));
fprintf('========================================================\n');

Tsub = T;
Tsub.Condition = removecats(Tsub.Condition);
Tsub.Condition = reordercats(Tsub.Condition, ["NB" "EBV1" "EBV2"]);

% DEFINED ONCE. NB is the reference level, so all contrasts are vs NB.
condLevels = ["NB" "EBV1" "EBV2"];
nCond = numel(condLevels);
cols  = [0.84 0.19 0.15;    % NB   red
         0.20 0.63 0.29;    % EBV1 green
         0.95 0.61 0.07];   % EBV2 orange

% Centre pressure so the intercept refers to the mean applied pressure
% rather than to 0 mmHg, which lies outside the data.
Tsub.Pc  = Tsub.Pressure - mean(Tsub.Pressure);
Tsub.Pc2 = Tsub.Pc.^2;
Pmean = mean(Tsub.Pressure);

tok = regexp(string(Tsub.ExplantID), 'N\s*(\d+)', 'tokens', 'once', 'ignorecase');
Tsub.ExpID = strings(height(Tsub),1);
for i = 1:height(Tsub)
    if isempty(tok{i}), Tsub.ExpID(i) = "UNPARSED";
    else,               Tsub.ExpID(i) = "N" + tok{i};
    end
end
fprintf('\nUnparsed filenames: %d\n', sum(Tsub.ExpID == "UNPARSED"));

%% ========================================================================
%  1. WEIGHTING
%  ========================================================================
%  Observations are weighted by inverse squared relative flow SD.
%  Since R = dP/Q with dP essentially fixed, relative error passes straight
%  through: sigma_R/R = sigma_Q/Q. And since d(logR)/dR = 1/R, the SD of
%  logR IS that relative error:  sigma_logR ~= FlowSD / Flow.
%
%  W_FLOOR caps the weight at 1/W_FLOOR^2, preventing a chance underestimate
%  of FlowSD from dominating the fit. Whether it binds is reported below.

relSD  = Tsub.FlowSD ./ Tsub.Flow;
Tsub.w = 1 ./ max(relSD, W_FLOOR).^2;

fprintf('\n--- WEIGHTS ---\n');
fprintf('Relative flow SD: median %.1f%%, IQR %.1f-%.1f%%, max %.0f%%\n', ...
    100*median(relSD), 100*prctile(relSD,25), 100*prctile(relSD,75), 100*max(relSD));
fprintf('Weight floor (%.0f%%) binds on %d of %d rows (%.1f%%)\n', ...
    100*W_FLOOR, sum(relSD < W_FLOOR), height(Tsub), 100*mean(relSD < W_FLOOR));

%% ========================================================================
%  2. MIXED-EFFECTS MODEL
%  ========================================================================
%  With three condition levels, treatment coding gives:
%    Pc                    slope in NB (the reference condition)
%    Condition_EBV1        level difference, EBV1 minus NB, at mean pressure
%    Condition_EBV2        level difference, EBV2 minus NB, at mean pressure
%    Pc:Condition_EBV1     slope difference, EBV1 minus NB
%    Pc:Condition_EBV2     slope difference, EBV2 minus NB
%
%  There is NO single interaction coefficient. "Do the slopes differ at all?"
%  is a joint test of both interaction terms simultaneously (2 df), obtained
%  from anova(). Individual coefficients are pairwise contrasts against NB.

%% ---- 2a. FIT WITH CONVERGENCE FALLBACK --------------------------------
%  With ~18 explants the full random structure may not be estimable. Two
%  common failure modes: the ExpID variance collapses to zero, or the
%  intercept-slope correlation hits +-1 (a boundary fit, reported without
%  error). The chain below tries progressively simpler structures.

forms = { ...
    'Resistance ~ Pc*Condition + (Pc|ExplantID) + (1|ExpID)', ...
    'Resistance ~ Pc*Condition + (Pc|ExplantID)', ...
    'Resistance ~ Pc*Condition + (1|ExplantID) + (1|ExpID)', ...
    'Resistance ~ Pc*Condition + (1|ExplantID)'};

mdl_w = []; usedForm = '';
for f = 1:numel(forms)
    try
        lastwarn('');
        m = fitlme(Tsub, forms{f}, 'FitMethod','REML', 'Weights', Tsub.w);
        [msg, ~] = lastwarn;
        if ~isempty(msg)
            fprintf('  [%s] warning: %s\n', forms{f}, msg);
        end
        mdl_w = m;  usedForm = forms{f};
        break
    catch ME
        fprintf('  [%s] FAILED: %s\n', forms{f}, ME.message);
    end
end
fprintf('\n--- 2a. PRIMARY: WEIGHTED LMM ---\n');
fprintf('Formula used: %s\n\n', usedForm);

[~,~,stw] = fixedEffects(mdl_w, 'DFMethod','satterthwaite');
disp(stw)

fprintf('Random effects:\n');
[~,~,re] = covarianceParameters(mdl_w);
disp(re{1})

% BOUNDARY CHECK: a correlation at +-1 or a variance at 0 means the random
% structure is over-specified for this sample size. Report the simpler model.
reTbl = re{1};
if any(strcmp(reTbl.Type,'corr'))
    cr = reTbl.Estimate(strcmp(reTbl.Type,'corr'));
    if any(abs(cr) > 0.99)
        fprintf('\n>> WARNING: intercept-slope correlation at boundary (%.3f).\n', cr);
        fprintf('   The random structure is over-specified. Consider refitting\n');
        fprintf('   with (1|ExplantID) and reporting that instead.\n');
    end
end
if any(reTbl.Estimate(strcmp(reTbl.Type,'std')) < 1e-6)
    fprintf('\n>> WARNING: a random-effect SD collapsed to zero.\n');
end

%% ---- 2b. OMNIBUS TESTS (ANOVA) ---------------------------------------
%  This is the section that replaces the single interaction p-value.
%    Pc            does resistance depend on pressure overall?
%    Condition     do the three conditions differ in level?      (2 df)
%    Pc:Condition  do the three conditions differ in slope?      (2 df)

fprintf('\n--- 2b. OMNIBUS TESTS (Type III ANOVA, Satterthwaite) ---\n');
av = anova(mdl_w, 'DFMethod','satterthwaite');
disp(av)

% Term naming varies between releases; match by content rather than literal.
iPc   = strcmp(av.Term,'Pc');
iCond = strcmp(av.Term,'Condition');
iInt  = contains(av.Term,'Pc') & contains(av.Term,'Condition');

p_omni_pc   = av.pValue(iPc);
p_omni_cond = av.pValue(iCond);
p_omni_int  = av.pValue(iInt);

fprintf('\nPressure effect            : p = %.4g\n', p_omni_pc);
fprintf('Condition (level, 2 df)    : p = %.4g\n', p_omni_cond);
fprintf('Condition x Pressure (2 df): p = %.4g   <- omnibus interaction\n', p_omni_int);

%% ---- 2c. PER-CONDITION SLOPES AND LEVELS ------------------------------
%  Each condition's slope is Pc plus its own interaction term. The standard
%  error of that SUM needs the covariance between the two coefficients, so
%  it cannot be read off the coefficient table -- hence the contrast vectors.

nm  = stw.Name;
nC  = numel(nm);
covB = mdl_w.CoefficientCovariance;
dfUse = stw.DF(strcmp(nm,'Pc'));

slope   = nan(nCond,1);  slopeLo = nan(nCond,1);  slopeHi = nan(nCond,1);
level   = nan(nCond,1);  levelLo = nan(nCond,1);  levelHi = nan(nCond,1);

for k = 1:nCond
    % slope contrast
    L = zeros(1,nC);  L(strcmp(nm,'Pc')) = 1;
    if k > 1
        L(strcmp(nm, sprintf('Pc:Condition_%s',condLevels(k)))) = 1;
        L(strcmp(nm, sprintf('Condition_%s:Pc',condLevels(k)))) = 1;  % name order varies
    end
    est = L*stw.Estimate;  se = sqrt(L*covB*L');
    slope(k)   = est;
    slopeLo(k) = est + tinv(0.025, dfUse)*se;
    slopeHi(k) = est + tinv(0.975, dfUse)*se;

    % level contrast (at Pc = 0, i.e. mean pressure)
    L = zeros(1,nC);  L(strcmp(nm,'(Intercept)')) = 1;
    if k > 1
        L(strcmp(nm, sprintf('Condition_%s',condLevels(k)))) = 1;
    end
    est = L*stw.Estimate;  se = sqrt(L*covB*L');
    level(k)   = est;
    levelLo(k) = est + tinv(0.025, dfUse)*se;
    levelHi(k) = est + tinv(0.975, dfUse)*se;
end

fprintf('\n--- 2c. PER-CONDITION ESTIMATES ---\n');
fprintf('%-6s %11s %22s %10s %20s\n', ...
    'Cond','slope/mmHg','95%% CI','fold 20-80','level at mean P');
for k = 1:nCond
    fprintf('%-6s %11.5f  [%+.5f, %+.5f] %9.2fx %8.2f [%.2f, %.2f]\n', ...
        condLevels(k), slope(k), slopeLo(k), slopeHi(k), exp(slope(k)*SPAN), ...
        exp(level(k)), exp(levelLo(k)), exp(levelHi(k)));
end

%% ---- 2d. PAIRWISE CONTRASTS ------------------------------------------
%  Only interpret these if the omnibus test is significant. With 5-7
%  explants per group they are descriptive.

fprintf('\n--- 2d. PAIRWISE CONTRASTS (descriptive at this n) ---\n');
pairs = nchoosek(1:nCond, 2);
for r = 1:size(pairs,1)
    a = pairs(r,1);  b = pairs(r,2);

    % slope difference
    L = zeros(1,nC);
    if a > 1
        L(strcmp(nm, sprintf('Pc:Condition_%s',condLevels(a)))) = -1;
        L(strcmp(nm, sprintf('Condition_%s:Pc',condLevels(a)))) = -1;
    end
    if b > 1
        L(strcmp(nm, sprintf('Pc:Condition_%s',condLevels(b)))) = 1;
        L(strcmp(nm, sprintf('Condition_%s:Pc',condLevels(b)))) = 1;
    end
    p_sl = coefTest(mdl_w, L);

    % level difference
    L2 = zeros(1,nC);
    if a > 1, L2(strcmp(nm, sprintf('Condition_%s',condLevels(a)))) = -1; end
    if b > 1, L2(strcmp(nm, sprintf('Condition_%s',condLevels(b)))) =  1; end
    p_lv = coefTest(mdl_w, L2);

    fprintf('%s vs %s : slope p = %.3f, level p = %.3f (%.2f-fold)\n', ...
        condLevels(a), condLevels(b), p_sl, p_lv, exp(level(b)-level(a)));
end

%% ---- 2e. CURVATURE CHECK ---------------------------------------------
%  ML, not REML: REML likelihoods are not comparable across different fixed
%  effects, because changing the fixed effects changes which residual
%  contrasts exist.

fprintf('\n--- 2e. CURVATURE CHECK (ML) ---\n');
randPart = extractAfter(usedForm, 'Pc*Condition ');
try
    mdl_linML  = fitlme(Tsub, ['Resistance ~ Pc*Condition ' randPart], 'FitMethod','ML');
    mdl_quadML = fitlme(Tsub, ['Resistance ~ (Pc + Pc2)*Condition ' randPart], 'FitMethod','ML');
    cmpQuad = compare(mdl_linML, mdl_quadML);
    disp(cmpQuad)
    if cmpQuad.pValue(2) < 0.05
        fprintf('>> CURVATURE PRESENT (p = %.4f): interpret the slope with care.\n', ...
            cmpQuad.pValue(2));
    else
        fprintf('>> Linear form adequate (p = %.4f).\n', cmpQuad.pValue(2));
    end
    p_curv = cmpQuad.pValue(2);
catch ME
    fprintf('Curvature check failed to converge: %s\n', ME.message);
    p_curv = NaN;
end

%% ---- 2f. SENSITIVITY: UNWEIGHTED AND DETECTION-LIMIT ------------------
fprintf('\n--- 2f. SENSITIVITY FITS ---\n');
Trel = Tsub(Tsub.Flow >= Q_LOD, :);
specNames = {'Weighted all (PRIMARY)','Unweighted all', ...
             sprintf('Unweighted >=%.1f',Q_LOD), sprintf('Weighted >=%.1f',Q_LOD)};
specMdls = cell(4,1);  specMdls{1} = mdl_w;
try, specMdls{2} = fitlme(Tsub, usedForm, 'FitMethod','REML'); catch, end
try, specMdls{3} = fitlme(Trel, usedForm, 'FitMethod','REML'); catch, end
try, specMdls{4} = fitlme(Trel, usedForm, 'FitMethod','REML','Weights',Trel.w); catch, end

specSlope = nan(4,1); specP = nan(4,1); specIntP = nan(4,1);
fprintf('%-26s %10s %9s %14s\n','Specification','NB slope','p','omnibus int p');
for k = 1:4
    if isempty(specMdls{k}), fprintf('%-26s  (did not converge)\n', specNames{k}); continue; end
    [~,~,st] = fixedEffects(specMdls{k}, 'DFMethod','satterthwaite');
    specSlope(k) = st.Estimate(strcmp(st.Name,'Pc'));
    specP(k)     = st.pValue(  strcmp(st.Name,'Pc'));
    a2 = anova(specMdls{k}, 'DFMethod','satterthwaite');
    specIntP(k)  = a2.pValue(contains(a2.Term,'Pc') & contains(a2.Term,'Condition'));
    fprintf('%-26s %10.4f %9.3g %14.3f\n', ...
        specNames{k}, specSlope(k), specP(k), specIntP(k));
end

% shorthand reused by the figures
b_Pc  = slope(1);  lo_Pc = slopeLo(1);  hi_Pc = slopeHi(1);
p_Pc  = stw.pValue(strcmp(nm,'Pc'));

%% ========================================================================
%  3. PER-EXPLANT SUMMARY TABLE
%  ========================================================================
%  All numeric columns preallocated as NaN. table('Size',...) fills doubles
%  with ZERO, which passes ~isnan() and enters tests as a real measurement.

ids = unique(Tsub.ExplantID);
nE  = numel(ids);

S = table(ids, strings(nE,1), categorical(repmat("",nE,1)), ...
    nan(nE,1), nan(nE,1), nan(nE,1), nan(nE,1), nan(nE,1), ...
    nan(nE,1), nan(nE,1), nan(nE,1), nan(nE,1), nan(nE,1), ...
    'VariableNames', {'ID','ExpID','Condition','slope','slope_w','R2', ...
                      'span','Pmid','nSteps','meanLogR','q0','q0_rel','noise'});
reason = strings(nE,1);

for i = 1:nE
    s = Tsub(Tsub.ExplantID == ids(i), :);

    S.ID(i)        = ids(i);
    S.ExpID(i)     = s.ExpID(1);
    S.Condition(i) = s.Condition(1);
    S.nSteps(i)    = height(s);
    S.meanLogR(i)  = mean(s.Resistance);
    S.Pmid(i)      = mean(s.Pressure);
    S.span(i)      = range(s.Pressure);
    S.noise(i)     = median(s.FlowSD ./ s.Flow);

    if height(s) < MIN_STEPS,        reason(i) = "too few steps";  continue; end
    if range(s.Pressure) < MIN_SPAN, reason(i) = "span too short"; continue; end

    b = polyfit(s.Pressure, s.Resistance, 1);
    S.slope(i) = b(1);

    % R2 descriptive only. NEVER filter on it: computed from the response,
    % so filtering selects on outcome and discards flat explants.
    yhat = polyval(b, s.Pressure);
    S.R2(i) = 1 - sum((s.Resistance - yhat).^2) / ...
                  sum((s.Resistance - mean(s.Resistance)).^2);

    % weighted slope -- same weights as the LMM, via lscov since polyfit
    % has no weights argument. X = [intercept column, predictor column],
    % so bw(1) is the intercept and bw(2) the slope (reverse of polyfit).
    w  = 1 ./ max(s.FlowSD ./ s.Flow, W_FLOOR).^2;
    X  = [ones(height(s),1), s.Pressure];
    bw = lscov(X, s.Resistance, w);
    S.slope_w(i) = bw(2);

    % q0: intercept of Q vs dP -- a CURVATURE indicator, not a leak test.
    bq = polyfit(s.Pressure, s.Flow, 1);
    S.q0(i)     = bq(2);
    S.q0_rel(i) = bq(2) / mean(s.Flow);
end

Sok = S(~isnan(S.slope), :);

fprintf('\n--- 3. RETENTION (min %d steps, min %d mmHg span) ---\n', MIN_STEPS, MIN_SPAN);
for k = 1:nCond
    nTot = sum(S.Condition==condLevels(k));
    nKep = sum(Sok.Condition==condLevels(k));
    fprintf('%-5s: %d of %d (%.0f%%)\n', condLevels(k), nKep, nTot, 100*nKep/max(nTot,1));
end
if any(reason ~= "")
    disp(groupsummary(table(S.Condition(reason~=""), reason(reason~=""), ...
        'VariableNames',{'Condition','Reason'}), {'Condition','Reason'}));
end

%% ========================================================================
%  4. PER-EXPLANT DESCRIPTIVES (model-free cross-check)
%  ========================================================================
%  One number per explant, then compared across conditions. Kruskal-Wallis
%  replaces the two-sample tests. It is legitimate here because each explant
%  contributes exactly ONE slope -- unlike a KW across pressure levels,
%  where the same explant would appear at every level.
%
%  At n = 5-7 per group these are DESCRIPTIVE. A null says little.

fprintf('\n--- 4a. PER-EXPLANT SLOPES (fold-change over %d mmHg) ---\n', SPAN);
fprintf('%-6s %4s %11s %11s %10s %10s %10s\n', ...
    'Cond','n','mean','median','fold','n positive','signrank p');
for k = 1:nCond
    sl = Sok.slope(Sok.Condition==condLevels(k));
    if numel(sl) < 2, fprintf('%-6s %4d  (too few)\n', condLevels(k), numel(sl)); continue; end
    psr = NaN;  if numel(sl) >= 5, psr = signrank(sl); end
    fprintf('%-6s %4d %11.5f %11.5f %9.2fx %6d/%-3d %10.3f\n', ...
        condLevels(k), numel(sl), mean(sl), median(sl), ...
        exp(mean(sl)*SPAN), sum(sl>0), numel(sl), psr);
end

fprintf('\nWeighted per-explant slopes:\n');
for k = 1:nCond
    sw = Sok.slope_w(Sok.Condition==condLevels(k));
    if numel(sw) < 2, continue; end
    psr = NaN;  if numel(sw) >= 5, psr = signrank(sw); end
    fprintf('%-6s %4d %11.5f %11.5f %9.2fx %6d/%-3d %10.3f\n', ...
        condLevels(k), numel(sw), mean(sw), median(sw), ...
        exp(mean(sw)*SPAN), sum(sw>0), numel(sw), psr);
end

fprintf('\n--- 4b. ACROSS CONDITIONS (Kruskal-Wallis) ---\n');
p_kw_slope = kruskalwallis(Sok.slope,    Sok.Condition, 'off');
p_kw_lvl   = kruskalwallis(Sok.meanLogR, Sok.Condition, 'off');
fprintf('Per-explant slope : p = %.3f\n', p_kw_slope);
fprintf('Mean logR (level) : p = %.3f\n', p_kw_lvl);

fprintf('\nLevel by condition (mean logR per explant):\n');
for k = 1:nCond
    lv = Sok.meanLogR(Sok.Condition==condLevels(k));
    if isempty(lv), continue; end
    fprintf('%-6s n=%d  median %.2f (%.2f mmHg.min/nL), IQR [%.2f, %.2f]\n', ...
        condLevels(k), numel(lv), median(lv), exp(median(lv)), ...
        prctile(lv,25), prctile(lv,75));
end

%% ========================================================================
%  5. DESIGN AND DATA-QUALITY CHECKS
%  ========================================================================

fprintf('\n--- 5a. DATASET ---\n');
fprintf('Observations : %d\n', height(Tsub));
for k = 1:nCond
    fprintf('  %-5s %d obs, %d explants\n', condLevels(k), ...
        sum(Tsub.Condition==condLevels(k)), sum(S.Condition==condLevels(k)));
end
fprintf('Experiments  : %d\n', numel(unique(S.ExpID)));
fprintf('Pressure     : %.0f to %.0f mmHg (mean %.1f)\n', ...
    min(Tsub.Pressure), max(Tsub.Pressure), Pmean);
fprintf('Steps/explant: median %d (range %d-%d)\n', ...
    median(S.nSteps), min(S.nSteps), max(S.nSteps));

fprintf('\n--- 5b. DESIGN CHECKS ---\n');
% Unequal pressure sampling biases the LEVEL comparison, since R rises with
% pressure: an explant sampled only at high dP shows a higher mean.
p_pmid = kruskalwallis(S.Pmid, S.Condition, 'off');
fprintf('Mean sampled pressure by condition (KW p = %.3f):\n', p_pmid);
for k = 1:nCond
    fprintf('  %-5s %.0f mmHg\n', condLevels(k), ...
        mean(S.Pmid(S.Condition==condLevels(k))));
end

% CONFOUNDING CHECK -- the important one at this n. If a condition sits in
% a single session, its comparison is confounded with that session and no
% model repairs it.
[~, ia] = unique(Tsub.ExplantID);
[tbl_x, ~, ~, lab_x] = crosstab(Tsub.ExpID(ia), Tsub.Condition(ia));
fprintf('\nExplants per experiment x condition:\n');
disp(array2table(tbl_x, 'RowNames', lab_x(1:size(tbl_x,1),1), ...
    'VariableNames', cellstr(lab_x(1:size(tbl_x,2),2))));
nAll3 = sum(all(tbl_x > 0, 2));
fprintf('Experiments containing all three conditions: %d of %d\n', nAll3, size(tbl_x,1));
for k = 1:size(tbl_x,2)
    nSess = sum(tbl_x(:,k) > 0);
    if nSess == 1
        fprintf('>> WARNING: %s appears in only ONE experiment -- condition is\n', ...
            lab_x{k,2});
        fprintf('   confounded with session and cannot be separated from it.\n');
    end
end

fprintf('\n--- 5c. FLOW DATA QUALITY ---\n');
ratio = Tsub.Flow ./ (Tsub.Pressure ./ exp(Tsub.Resistance));
fprintf('Flow / reconstructed dP/R: median %.3f (IQR %.3f-%.3f)\n', ...
    median(ratio), prctile(ratio,25), prctile(ratio,75));
fprintf('Flow range: %.2f to %.0f nL/min\n', min(Tsub.Flow), max(Tsub.Flow));
fprintf('Non-positive flows: %d\n', sum(Tsub.Flow <= 0));
fprintf('Near saturation (>%d): %d rows\n', Q_SAT, sum(Tsub.Flow > Q_SAT));
for k = 1:nCond
    n = sum(Tsub.Condition==condLevels(k));
    b = sum(Tsub.Condition==condLevels(k) & Tsub.Flow < Q_LOD);
    fprintf('%-5s below LOD (%.1f nL/min): %d of %d (%.1f%%)\n', ...
        condLevels(k), Q_LOD, b, n, 100*b/max(n,1));
end
nLow = sum(Tsub.Flow < Q_LOD & Tsub.Pressure <= 45);
nTotLow = sum(Tsub.Flow < Q_LOD);
if nTotLow > 0
    fprintf('Sub-LOD at <=40 mmHg: %d of %d (%.0f%%)\n', nLow, nTotLow, 100*nLow/nTotLow);
end

%% ========================================================================
%  6. MEASUREMENT DIAGNOSTICS
%  ========================================================================
%  ON q0. A positive q0 does NOT indicate a leak. If resistance rises with
%  pressure, Q = dP/R(dP) grows sub-linearly, so the Q-vs-dP curve is
%  CONCAVE, and a straight line fitted to it crosses the y-axis above zero.
%  Example: Q = 10*sqrt(dP) gives Q(30) = 54.8 and Q(110) = 104.9; the line
%  through those points has intercept +36 -- pure geometry.
%
%  A leak would be ADDITIVE on top of that, so it shows as the INTERCEPT of
%  the q0-vs-slope regression, not in the correlation. Scale is a further
%  argument: a real seal failure delivers tens to hundreds of nL/min.

ok = ~isnan(S.q0) & abs(S.q0) < 100;
nExcl = sum(~isnan(S.q0) & abs(S.q0) >= 100);

rho = NaN; prho = NaN; rho_n = NaN; p_n = NaN;
if sum(ok) >= 5
    [rho, prho] = corr(S.q0(ok), S.slope(ok), 'Type','Spearman', 'rows','complete');
end
g2 = ~isnan(S.noise) & ~isnan(S.slope);
if sum(g2) >= 5
    [rho_n, p_n] = corr(S.noise(g2), abs(S.slope(g2)), 'Type','Spearman');
end

figure('Position',[80 80 1050 780]);

subplot(2,2,1);
histogram(S.q0(ok), max(6,round(sum(ok)/3)), 'FaceColor',[0.35 0.55 0.8]);
xline(0,'r','LineWidth',2);
if sum(ok) > 0, xline(median(S.q0(ok)),'k--','LineWidth',1.5); end
xlabel('fitted Q at \DeltaP = 0 (nL/min)'); ylabel('explants');
title(sprintf('A. Apparent offset: median %.1f, %d/%d positive', ...
    median(S.q0(ok)), sum(S.q0(ok)>0), sum(ok)), 'FontSize',10);
box on

subplot(2,2,2); hold on
for k = 1:nCond
    sel = ok & S.Condition==condLevels(k);
    scatter(S.slope(sel), S.q0(sel), 55, cols(k,:), 'filled', 'MarkerFaceAlpha',0.7);
end
if sum(ok) >= 5
    pf = polyfit(S.slope(ok), S.q0(ok), 1);
    xg = linspace(min(S.slope(ok)), max(S.slope(ok)), 50);
    plot(xg, polyval(pf, xg), 'k-', 'LineWidth', 1.5);
end
yline(0,'k--'); xline(0,'k--');
xlabel('per-explant logR slope (/mmHg)'); ylabel('q_0 (nL/min)');
title(sprintf('B. q_0 vs slope: \\rho = %.2f, p = %.3g', rho, prho), 'FontSize',10);
legend(condLevels,'Location','southeast'); grid on; box on

subplot(2,2,3); hold on
edges = 5:10:115;
for k = 1:nCond
    histogram(Tsub.Pressure(Tsub.Flow < Q_LOD & Tsub.Condition==condLevels(k)), ...
        'BinEdges', edges, 'FaceColor', cols(k,:), 'FaceAlpha',0.5);
end
xlabel('\DeltaP (mmHg)'); ylabel('sub-LOD measurements');
title(sprintf('C. Detection floor: %d of %d at \\leq40 mmHg', nLow, nTotLow), 'FontSize',10);
legend(condLevels,'Location','northeast'); grid on; box on

subplot(2,2,4); hold on
for k = 1:nCond
    sel = S.Condition==condLevels(k);
    scatter(S.noise(sel), abs(S.slope(sel)), 55, cols(k,:), 'filled', 'MarkerFaceAlpha',0.7);
end
xlabel('median relative flow SD'); ylabel('|per-explant slope| (/mmHg)');
title(sprintf('D. Slope magnitude vs noise: \\rho = %.2f, p = %.3f', rho_n, p_n), 'FontSize',10);
legend(condLevels,'Location','northeast'); grid on; box on

sgtitle('Measurement diagnostics');

fprintf('\n--- 6. DIAGNOSTICS ---\n');
fprintf('A  Median q0 = %.2f nL/min, positive in %d of %d (%d excluded, |q0|>100)\n', ...
    median(S.q0(ok)), sum(S.q0(ok)>0), sum(ok), nExcl);
fprintf('B  q0 vs slope: rho = %.2f, p = %.3g\n', rho, prho);
fprintf('D  |slope| vs noise: rho = %+.2f, p = %.3f\n', rho_n, p_n);

%% ========================================================================
%  7. FIGURES
%  ========================================================================

%% ---- 7a. Per-explant slopes by condition ------------------------------
figure; hold on
for k = 1:nCond
    sl = Sok.slope(Sok.Condition==condLevels(k));
    if isempty(sl), continue; end
    swarmchart(k*ones(numel(sl),1), sl, 60, cols(k,:), 'filled', 'MarkerFaceAlpha',0.7);
    plot([k-0.25 k+0.25], median(sl)*[1 1], 'k-',  'LineWidth',2);
    plot([k-0.25 k+0.25], mean(sl)*[1 1],   'k--', 'LineWidth',1.5);
end
yline(0,'k:');
yl = ylim;
for k = 1:nCond
    n = sum(Sok.Condition==condLevels(k));
    text(k, yl(1) + 0.03*range(yl), sprintf('n=%d', n), ...
        'HorizontalAlignment','center','FontSize',9);
end
text(0.03, 0.96, sprintf('Kruskal-Wallis p = %.2f', p_kw_slope), ...
    'Units','normalized','FontSize',9);
text(0.03, 0.92, 'solid = median, dashed = mean', ...
    'Units','normalized','FontSize',8,'Color',[0.4 0.4 0.4]);
xticks(1:nCond); xticklabels(condLevels); xlim([0.5 nCond+0.5]);
ylabel('per-explant logR slope (/mmHg)');
title('Pressure dependence of resistance, by condition');
box on; grid on

%% ---- 7b. Weighted mixed-effects fit -----------------------------------
Pgrid = (10:5:110)';  ng = numel(Pgrid);
PredTbl = table( ...
    repmat(Pgrid, nCond, 1) - Pmean, ...
    categorical(repelem(condLevels(:), ng), condLevels), ...
    repmat(Tsub.ExplantID(1), nCond*ng, 1), ...
    repmat(Tsub.ExpID(1), nCond*ng, 1), ...
    'VariableNames', {'Pc','Condition','ExplantID','ExpID'});
if ~contains(usedForm,'ExpID'), PredTbl.ExpID = []; end

[yp, yCI] = predict(mdl_w, PredTbl, 'Conditional', false);

figure; hold on
gscatter(Tsub.Pressure, Tsub.Resistance, Tsub.Condition, cols, '.', 12);
legEntries = cellstr(condLevels);
for k = 1:nCond
    idx = PredTbl.Condition == condLevels(k);
    fill([Pgrid; flipud(Pgrid)], [yCI(idx,1); flipud(yCI(idx,2))], ...
        cols(k,:), 'FaceAlpha',0.15, 'EdgeColor','none');
    plot(Pgrid, yp(idx), 'Color', cols(k,:), 'LineWidth', 2);
    legEntries{end+1} = sprintf('%s CI', condLevels(k)); %#ok<SAGROW>
    legEntries{end+1} = sprintf('%s fit', condLevels(k)); %#ok<SAGROW>
end
xlabel('\DeltaP (mmHg)'); ylabel('logR (mmHg\cdotmin/nL)');
title('Weighted mixed-effects fit');
legend(legEntries, 'Location','southeast');
grid on; box on

ax = gca;
for k = 1:nCond
    text(ax, 0.02, 0.96-0.04*(k-1), ...
        sprintf('\\itSlope\\rm %s = %.4f /mmHg', condLevels(k), slope(k)), ...
        'Units','normalized','Color',cols(k,:),'FontSize',9);
end
text(ax, 0.02, 0.96-0.04*nCond, ...
    sprintf('%s 95%% CI: [%.4f, %.4f]', condLevels(1), slopeLo(1), slopeHi(1)), ...
    'Units','normalized','Color',cols(1,:),'FontSize',9);
text(ax, 0.02, 0.96-0.04*(nCond+1), ...
    sprintf('R rises %.2f-fold from %d to %d mmHg [%.2f, %.2f]', ...
    exp(slope(1)*SPAN), P1, P2, exp(slopeLo(1)*SPAN), exp(slopeHi(1)*SPAN)), ...
    'Units','normalized','Color','k','FontSize',9);

text(ax, 0.55, 0.96, sprintf('Omnibus slope difference (2 df): p = %.3g', p_omni_int), ...
    'Units','normalized','Color','k','FontSize',9);
text(ax, 0.55, 0.92, sprintf('Omnibus level difference (2 df): p = %.3g', p_omni_cond), ...
    'Units','normalized','Color','k','FontSize',9);
text(ax, 0.55, 0.87, sprintf('Pressure effect: p = %.3g', p_omni_pc), ...
    'Units','normalized','Color','k','FontSize',9,'FontWeight','bold');
text(ax, 0.55, 0.82, sprintf('n = %s explants', ...
    strjoin(arrayfun(@(k) sprintf('%d',sum(S.Condition==condLevels(k))), ...
    1:nCond, 'UniformOutput', false), '/')), ...
    'Units','normalized','Color',[0.4 0.4 0.4],'FontSize',8);

%% ---- 7c. Spaghetti: logR trajectories ---------------------------------
figure('Position',[100 100 1400 420]);
b0_ref = stw.Estimate(strcmp(nm,'(Intercept)'));
for k = 1:nCond
    subplot(1,nCond,k); hold on
    sel = find(S.Condition == condLevels(k) & ~isnan(S.slope));
    for j = 1:numel(sel)
        s = Tsub(Tsub.ExplantID == S.ID(sel(j)), :);
        [Ps, o] = sort(s.Pressure);
        plot(Ps, s.Resistance(o), '-o', 'Color', [cols(k,:) 0.5], ...
            'MarkerSize', 4, 'MarkerFaceColor', cols(k,:), 'LineWidth', 1.0);
    end
    plot(Pgrid, level(k) + slope(k)*(Pgrid - Pmean), 'k-', 'LineWidth', 2.5);
    xlabel('\DeltaP (mmHg)'); ylabel('logR (mmHg\cdotmin/nL)');
    title(sprintf('%s (n = %d)', condLevels(k), numel(sel)));
    xlim([0 120]); grid on; box on
end
% shared y-axis so panels are visually comparable
allAx = findobj(gcf,'Type','axes');
linkaxes(allAx,'y');
sgtitle('Per-explant resistance trajectories with fitted population mean');

%% ---- 7d. Spaghetti: raw Q vs dP ---------------------------------------
%  The raw measurement, before any ratio is taken. Log y-axis because flows
%  span orders of magnitude. Panel density differs, so compare the fitted
%  black lines rather than the apparent spread.
figure('Position',[100 100 1400 420]);
for k = 1:nCond
    subplot(1,nCond,k); hold on
    sel = find(S.Condition == condLevels(k) & ~isnan(S.slope));
    for j = 1:numel(sel)
        s = Tsub(Tsub.ExplantID == S.ID(sel(j)), :);
        [Ps, o] = sort(s.Pressure);
        plot(Ps, s.Flow(o), '-o', 'Color', [cols(k,:) 0.5], ...
            'MarkerSize', 4, 'MarkerFaceColor', cols(k,:), 'LineWidth', 1.0);
    end
    % plot(Pgrid, Pgrid ./ exp(level(k) + slope(k)*(Pgrid - Pmean)), ...
    %     'k-', 'LineWidth', 2.5);
    %yline(Q_LOD, 'k--', 'Q_{LOD}', 'LineWidth', 1.2);
    xlabel('\DeltaP (mmHg)'); ylabel('Q (nL/min)');
    title(sprintf('%s (n = %d)', condLevels(k), numel(sel)));
    set(gca,'YScale','log'); xlim([0 115]);
    grid on; box on
end
allAx = findobj(gcf,'Type','axes');
linkaxes(allAx,'y');
sgtitle('Flow vs applied pressure, per explant');

%% ---- 7e. Detection ceiling overlay ------------------------------------
%  The dashed curve is the highest resistance the sensor could detect at
%  each pressure: Q > Q_LOD  <=>  logR < log(dP) - log(Q_LOD). Below the
%  line is measurable; above it, flow fell under the floor. If the top edge
%  of the cloud hugs the curve, censoring is shaping the trend.
Pg = linspace(min(Tsub.Pressure), max(Tsub.Pressure), 200);
figure; hold on
gscatter(Tsub.Pressure, Tsub.Resistance, Tsub.Condition, cols, '.', 14);
plot(Pg, log(Pg / Q_LOD), 'k--', 'LineWidth', 1.5);
xlabel('\DeltaP (mmHg)'); ylabel('logR (mmHg\cdotmin/nL)');
legend([cellstr(condLevels), {sprintf('detection ceiling (Q_{LOD} = %.1f)',Q_LOD)}], ...
    'Location','southeast');
title('Data against the flow-sensor detection ceiling');
grid on; box on

%% ========================================================================
%  8. NEGATIVE-SLOPE EXPLANTS (inspection list -- NOT excluded)
%  ========================================================================
neg = sortrows(S(~isnan(S.slope) & S.slope < 0, :), 'slope');

fprintf('\n--- 8. NEGATIVE-SLOPE EXPLANTS ---\n');
fprintf('%d of %d retained explants\n', height(neg), sum(~isnan(S.slope)));
for k = 1:nCond
    fprintf('  %-5s %d of %d\n', condLevels(k), ...
        sum(neg.Condition==condLevels(k)), ...
        sum(S.Condition==condLevels(k) & ~isnan(S.slope)));
end
fprintf('\n');

for i = 1:height(neg)
    s = Tsub(Tsub.ExplantID == neg.ID(i), :);
    rsd = s.FlowSD ./ s.Flow;
    fprintf('--- %s\n', string(neg.ID(i)));
    fprintf('    %s | %s | slope %+.4f (weighted %+.4f) | R2 %.2f\n', ...
        string(neg.Condition(i)), neg.ExpID(i), neg.slope(i), neg.slope_w(i), neg.R2(i));
    fprintf('    %d steps, %.0f-%.0f mmHg, median rel SD %.0f%%\n', ...
        height(s), min(s.Pressure), max(s.Pressure), 100*median(rsd));
    flags = strings(0);
    if any(s.Flow < Q_LOD), flags(end+1) = "sub-LOD flow"; end %#ok<SAGROW>
    if any(s.Flow > Q_SAT), flags(end+1) = "near saturation"; end %#ok<SAGROW>
    if max(rsd) > 0.5, flags(end+1) = sprintf("unstable step (%.0f%%)", 100*max(rsd)); end %#ok<SAGROW>
    if abs(neg.slope_w(i) - neg.slope(i)) > 0.005
        flags(end+1) = "weighting changes slope substantially"; %#ok<SAGROW>
    end
    if ~isempty(flags), fprintf('    FLAGS: %s\n', strjoin(flags, '; ')); end
    [~, o] = sort(s.Pressure);
    fprintf('    %8s %10s %8s %8s\n', 'P(mmHg)','Q(nL/min)','relSD','logR');
    for j = 1:numel(o)
        kk = o(j);  mark = "";
        if s.Flow(kk) < Q_LOD, mark = mark + " <LOD";  end
        if rsd(kk) > 0.5,      mark = mark + " NOISY"; end
        fprintf('    %8.1f %10.2f %7.0f%% %8.2f%s\n', ...
            s.Pressure(kk), s.Flow(kk), 100*rsd(kk), s.Resistance(kk), mark);
    end
    fprintf('\n');
end

%% ========================================================================
%  9. SUMMARY
%  ========================================================================
fprintf('\n========================================================\n');
fprintf('SUMMARY -- THREE CONDITIONS\n');
fprintf('========================================================\n');

fprintf('\nModel: %s\n', usedForm);
fprintf('n = %s explants (%s), %d experiments\n', ...
    strjoin(arrayfun(@(k) sprintf('%d',sum(S.Condition==condLevels(k))), ...
        1:nCond,'UniformOutput',false), '/'), ...
    strjoin(cellstr(condLevels), '/'), numel(unique(S.ExpID)));

fprintf('\n1. OMNIBUS TESTS\n');
fprintf('   Pressure effect             : p = %.4g\n', p_omni_pc);
fprintf('   Condition, level (2 df)     : p = %.4g\n', p_omni_cond);
fprintf('   Condition x Pressure (2 df) : p = %.4g\n', p_omni_int);

fprintf('\n2. PER-CONDITION SLOPES (fold-change %d to %d mmHg)\n', P1, P2);
for k = 1:nCond
    fprintf('   %-5s %.5f/mmHg [%+.5f, %+.5f] = %.2f-fold [%.2f, %.2f]\n', ...
        condLevels(k), slope(k), slopeLo(k), slopeHi(k), ...
        exp(slope(k)*SPAN), exp(slopeLo(k)*SPAN), exp(slopeHi(k)*SPAN));
end

fprintf('\n3. PER-CONDITION LEVELS at %.0f mmHg\n', Pmean);
for k = 1:nCond
    fprintf('   %-5s %.2f mmHg.min/nL [%.2f, %.2f]\n', ...
        condLevels(k), exp(level(k)), exp(levelLo(k)), exp(levelHi(k)));
end

fprintf('\n4. MODEL-FREE CROSS-CHECK (Kruskal-Wallis on per-explant values)\n');
fprintf('   slope p = %.3f, level p = %.3f\n', p_kw_slope, p_kw_lvl);

fprintf('\n5. CAVEATS\n');
fprintf('   - n is 5-7 per condition. Treat all comparisons as DESCRIPTIVE:\n');
fprintf('     an omnibus null does not establish equivalence at this size.\n');
fprintf('   - Pressure was applied as a monotonic ascending ramp without\n');
fprintf('     pauses, so applied pressure and elapsed time are confounded.\n');
fprintf('     All conditions share this, so it does not affect the contrast.\n');
if ~isnan(p_curv)
    fprintf('   - Curvature check: p = %.3f\n', p_curv);
end
fprintf('========================================================\n');

%% ========================================================================
%  10. SAVE
%  ========================================================================
stamp = datestr(now,'yyyymmdd_HHMM');
writetable(S, sprintf('explant_summary_3cond_%s.csv', stamp));
save(sprintf('resistance_3cond_%s.mat', stamp), ...
    'S','Sok','Tsub','mdl_w','usedForm','slope','slopeLo','slopeHi', ...
    'level','levelLo','levelHi','av','p_omni_pc','p_omni_cond','p_omni_int');

fprintf('\nSaved: explant_summary_3cond_%s.csv\n', stamp);
fprintf('Saved: resistance_3cond_%s.mat\n', stamp);
diary off
fprintf('Log: %s\n', logName);