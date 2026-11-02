%% run_comparison.m
%  Descriptive two-level comparison at matched pressures. SINGLE self-contained
%  script. Pick files ONCE; after that, switching metric (R<->Q) or restyling the
%  plot just needs another Run - no dialogs, because the raw data is cached in
%  the workspace (RAW). Dialogs return only if RAW is missing or reselect = true.
%
%  Boxes over per-explant values, points overlaid, n(explants) under each box.
%  No tests - across-pressure inference lives in the LMM pipeline.

close all; clc;          % NOTE: no 'clear' - that is what keeps RAW between runs

%% ===================== CONFIG (edit freely, then Run) =====================
metric   = 'Q';          % 'R' (resistance) or 'Q' (flow)  <- flip and re-Run, no re-picking
reselect = false;       % true = re-pick files this run; false = reuse cached RAW

% resVar : resistance variable per level ; flowVar : flow variable per level
% (iPERF files may lack 'average_flow1_off', so it reads 'average_flow1' instead)
levels = struct( ...
    'resVar',  {'R_cons_offset',             'R_cons_offset'}, ...
    'flowVar', {'average_flow1', 'average_flow1_off'}, ...
    'label',   {'4434',         'mEER'}, ...
    'color',   {'m',             'b'});

pressure_ranges = {[19 30], [49 59], [76 85], [100 200] };  % matched-pressure bins (mbar) [19 30], [76 85], ,[100 200]
commonBeginning = 'DP_F_R_STD_';
Rdivide         = 1.33;   % mbar -> mmHg (resistance only)
Rmax            = 80;     % raw-resistance upper filter
Qmax            = 500;    % flow upper filter !!!!READ ME CHANGE ACCORDINGLY TO NRRDS
show_explant_sd = false;
bin_display     = 'all'; % 'all' (empty side = n=0) | 'both' (only bins both levels fill) | 'any'

barrierLabels  = {'NB','EBV1'};
barrierMarkers = {'o','s'};      % shape = barrier; colour = level

% cosmetics
groupGap = 3; offset = 0.55; jitter = 0.5;
xLabel   = '\DeltaP (mmHg)';
grid_on  = true;
ylog     = false;         % true = log y-axis (data unchanged, axis only)
% =========================================================================

nBins = numel(pressure_ranges);

%% ---- collect RAW once (the only part that opens dialogs) ----
if reselect || ~exist('RAW','var') || isempty(RAW)
    RAW = struct('level',{},'bcode',{},'name',{},'p',{},'yR',{},'yQ',{});
    for L = 1:2
        folder = uigetdir('', sprintf('Select the folder with %s explant files', levels(L).label));
        if isequal(folder, 0), error('No folder selected for %s.', levels(L).label); end
        mf = dir(fullfile(folder, [commonBeginning '*.mat']));
        if isempty(mf), error('No files matching %s* in\n  %s', commonBeginning, folder); end
        names = {mf.name}';

        [sel, ok] = listdlg('PromptString', sprintf('Select %s explant files', levels(L).label), ...
            'SelectionMode', 'multiple', 'ListSize', [400 400], 'ListString', names);
        if ~ok || isempty(sel), error('No files selected for %s.', levels(L).label); end

        % optional exclusion
        exclAnswer = questdlg(sprintf('Exclude any files from %s?', levels(L).label), ...
            'Exclude Data?', 'Yes', 'No', 'No');
        if strcmp(exclAnswer, 'Yes')
            selNames = names(sel);
            [exclIdx, okE] = listdlg('PromptString', 'Pick any files to EXCLUDE', ...
                'SelectionMode', 'multiple', 'ListSize', [400 400], 'ListString', selNames);
            if okE && ~isempty(exclIdx), sel(exclIdx) = []; end
        end
        if isempty(sel), error('All files were excluded for %s.', levels(L).label); end

        % barrier tagging (default EBV1; pick NB)
        selNames = names(sel);
        bcodeSel = 2 * ones(numel(sel), 1);
        nbSel = listdlg('PromptString', sprintf('%s: pick NB files (rest = EBV1)', levels(L).label), ...
            'SelectionMode', 'multiple', 'ListSize', [400 400], 'ListString', selNames);
        bcodeSel(nbSel) = 1;

        % load raw vectors once per file (both metrics stored)
               for si = 1:numel(sel)
            f = sel(si);
            d = load(fullfile(folder, mf(f).name));

            % integrity check on the raw file, before storing
            p  = d.average_pressure_off(:);
            yR = d.(levels(L).resVar)(:);
            if isfield(d, levels(L).flowVar), yQ = d.(levels(L).flowVar)(:); else, yQ = []; end
            if numel(p) ~= numel(yR) || (~isempty(yQ) && numel(p) ~= numel(yQ))
                fprintf('SKIP (length mismatch): %s\n', mf(f).name);
                continue
            end

            k = numel(RAW) + 1;
            RAW(k).level = L;
            RAW(k).bcode = bcodeSel(si);
            RAW(k).name  = mf(f).name;
            RAW(k).p     = p;
            RAW(k).yR    = yR;
            RAW(k).yQ    = yQ;
        end
    end
    fprintf('Collected %d explants into RAW.\n', numel(RAW));
else
    fprintf('Reusing %d cached explants (set reselect = true to re-pick).\n', numel(RAW));
end

%% ---- build the chosen metric from RAW (instant, no dialogs) ----
levelMean  = cell(2, nBins);
levelMedian = cell(2, nBins);
levelSD    = cell(2, nBins);
levelGroup = cell(2, nBins);
for k = 1:numel(RAW)
    L = RAW(k).level; bcode = RAW(k).bcode; p = RAW(k).p;
    if strcmp(metric,'R'), y = RAW(k).yR; else, y = RAW(k).yQ; end
    if isempty(y), continue; end     % file lacks this metric (e.g. iPERF flow)
    for j = 1:nBins
        lo = pressure_ranges{j}(1); hi = pressure_ranges{j}(2);
        if strcmp(metric,'R')
            v = p>=lo & p<=hi & y>0 & y<Rmax; vals = y(v)/Rdivide;
        else
            v = p>=lo & p<=hi & y>0 & y<Qmax; vals = y(v);
        end
        if any(v)
            levelMean{L,j}(end+1,1)  = mean(vals);
            levelMedian{L,j}(end+1,1)  = median(vals);
            levelGroup{L,j}(end+1,1) = bcode;
            if nnz(v)>1, levelSD{L,j}(end+1,1) = std(vals);
            else,        levelSD{L,j}(end+1,1) = 0; end
        end
    end
end

%% ---- decide which bins to show ----
hasData = false(2, nBins);
for L = 1:2
    for j = 1:nBins, hasData(L,j) = ~isempty(levelMean{L,j}); end
end
switch lower(bin_display)
    case 'all',  keep = true(1, nBins);
    case 'any',  keep = hasData(1,:) | hasData(2,:);
    case 'both', keep = hasData(1,:) & hasData(2,:);
    otherwise,   error('bin_display must be ''all'', ''any'', or ''both''.');
end
binIdx = find(keep);
if isempty(binIdx), warning('No bins to plot under bin_display=''%s''.', bin_display); return; end
nShow = numel(binIdx);

%% ---- draw ----
figure; hold on;
xbase = (1:nShow) * groupGap;

allvals = [];
for kk = 1:nShow
    j = binIdx(kk);
    for L = 1:2
        vals = levelMean{L,j};
        if isempty(vals), continue; end
        if L == 1, xo = -offset; else, xo = +offset; end
        x = xbase(kk) + xo;

        boxplot(vals, 'Positions', x, 'Widths', 0.6, 'Symbol', '');
        xs = x + (rand(numel(vals),1) - 0.5) * jitter;
        grp = levelGroup{L,j};
        for b = 1:numel(barrierMarkers)
            mb = grp == b;
            if ~any(mb), continue; end
            scatter(xs(mb), vals(mb), 26, 'filled', 'Marker', barrierMarkers{b}, ...
                'MarkerFaceColor', levels(L).color, 'MarkerFaceAlpha', 0.75);
        end
        if show_explant_sd
            sd = levelSD{L,j}; m = sd > 0;
            if any(m)
                errorbar(xs(m), vals(m), sd(m), 'LineStyle','none', 'Color', [0.5 0.5 0.5], 'CapSize', 0);
            end
        end
        allvals = [allvals; vals]; %#ok<AGROW>
    end
end
if isempty(allvals), warning('No data collected.'); return; end

% n(explants) under each box
ymin = min(allvals); ymax = max(allvals); yr = max(ymax - ymin, eps);
ybase = ymin - 0.10*yr;
for kk = 1:nShow
    j = binIdx(kk);
    text(xbase(kk)-offset, ybase, sprintf('n=%d', numel(levelMean{1,j})), 'HorizontalAlignment','center','FontSize',8);
    text(xbase(kk)+offset, ybase, sprintf('n=%d', numel(levelMean{2,j})), 'HorizontalAlignment','center','FontSize',8);
end
ylim([ybase - 0.05*yr, ymax + 0.08*yr]);

xticklabs = arrayfun(@(kk) sprintf('%d-%d', pressure_ranges{binIdx(kk)}(1), pressure_ranges{binIdx(kk)}(2)), ...
    1:nShow, 'UniformOutput', false);
set(gca, 'XTick', xbase, 'XTickLabel', xticklabs, 'FontSize', 11);
xlim([xbase(1)-groupGap*0.7, xbase(end)+groupGap*0.7]);
xlabel(xLabel);
if strcmp(metric,'R'), ylabel('Resistance (mmHg/nL/min)'); else, ylabel('Flow rate (nL/min)'); end

hLevel(1) = scatter(nan,nan,26,'filled','MarkerFaceColor',levels(1).color);
hLevel(2) = scatter(nan,nan,26,'filled','MarkerFaceColor',levels(2).color);
hBar = gobjects(1,numel(barrierMarkers));
for b = 1:numel(barrierMarkers)
    hBar(b) = scatter(nan,nan,26,'filled','Marker',barrierMarkers{b},'MarkerFaceColor','k');
end
legend([hLevel hBar], [{levels(1).label, levels(2).label}, barrierLabels], 'Location','northwest');
if grid_on, grid on; end
if ylog, set(gca,'YScale','log'); end
box on; hold off;

%% ---- caption stats (per-explant summaries; no tests) ----
if strcmp(metric,'R'), mname = 'Resistance (mmHg/nL/min)'; else, mname = 'Flow (nL/min)'; end
fprintf('\n=== %s | %s vs %s | per-explant summaries ===\n', mname, levels(1).label, levels(2).label);
for j = 1:nBins
    for L = 1:2
        vals = levelMean{L,j};
        if isempty(vals)
            fprintf('  %4d-%-4d  %-10s  n=0\n', pressure_ranges{j}(1), pressure_ranges{j}(2), levels(L).label);
        else
            q = prctile(vals, [25 50 75]);
            fprintf('  %4d-%-4d  %-10s  n=%2d  median=%6.2f  IQR=[%6.2f, %6.2f]  mean=%6.2f  SD=%5.2f\n', ...
                pressure_ranges{j}(1), pressure_ranges{j}(2), levels(L).label, ...
                numel(vals), q(2), q(1), q(3), mean(vals), std(vals));
        end
    end
end