function diagnostics_metrics()
    cfg = config();
    if ~exist(cfg.results_dir, 'dir')
        mkdir(cfg.results_dir);
    end

    resultsRoot = fileparts(cfg.results_dir);
    pdfDir = fullfile(resultsRoot, 'figures_pdf');
    if ~exist(pdfDir, 'dir')
        mkdir(pdfDir);
    end

    keys = {'baseline','inner_light','ball_light','outer_light','inner_severe','ball_severe','outer_severe'};
    labels = {"Baseline","Inner Light","Ball Light","Outer Light","Inner Severe","Ball Severe","Outer Severe"};
    targets = {'FTF','BPFI','BSF','BPFO','BPFI','BSF','BPFO'};
    maxPlotFreq = 6000;
    bandHalfWidth = 5;
    rpmFallback = 1797;

    numFiles = numel(keys);
    rpmVals = zeros(numFiles,1);
    rmsVals = zeros(numFiles,1);
    crestVals = zeros(numFiles,1);
    kurtVals = zeros(numFiles,1);
    bandEnergyVals = zeros(numFiles,1);

    baselinePath = fullfile(cfg.processed_dir, 'baseline.mat');
    if ~isfile(baselinePath)
        error('Arquivo baseline processado não encontrado: %s', baselinePath);
    end
    baselineSample = load(baselinePath);
    baselineSig = baselineSample.clean_sig(:);
    baselineFs = read_field(baselineSample, 'fs', cfg.fs);
    [baselinePSD, baselineFreq] = compute_psd(baselineSig, baselineFs);

    for idx = 1:numFiles
        key = keys{idx};
        label = labels{idx};
        targetName = targets{idx};
        dataPath = fullfile(cfg.processed_dir, [key '.mat']);
        if ~isfile(dataPath)
            error('Arquivo processado não encontrado: %s', dataPath);
        end

        sample = load(dataPath);
        if ~isfield(sample, 'clean_sig')
            error('Arquivo %s não contém clean_sig. Execute o ETL antes.', dataPath);
        end
        signal = sample.clean_sig(:);
        fs = read_field(sample, 'fs', cfg.fs);
        rpmValue = read_field(sample, 'rpm', rpmFallback);

        freqs = compute_fault_frequencies(rpmValue);
        targetFreq = freqs.(targetName);

        [spec1, f1] = method1_envelope(signal, fs);
        [samplePSD, sampleFreq] = compute_psd(signal, fs);

        figPSD = plot_psd_comparison(baselineFreq, baselinePSD, sampleFreq, samplePSD, label, maxPlotFreq);
        saveas(figPSD, fullfile(cfg.results_dir, sprintf('%s_psd_compare.png', key)));
        exportgraphics(figPSD, fullfile(pdfDir, sprintf('%s_psd_compare.pdf', key)), 'ContentType', 'vector');
        % Removed close(figPSD);

        figMarkers = plot_fault_markers(f1, spec1, freqs, targetName, label, maxPlotFreq);
        saveas(figMarkers, fullfile(cfg.results_dir, sprintf('%s_markers_%s.png', key, lower(targetName))));
        exportgraphics(figMarkers, fullfile(pdfDir, sprintf('%s_markers_%s.pdf', key, lower(targetName))), 'ContentType', 'vector');

        if contains(key, 'ball')
            rawFile = cfg.files.(key);
            create_ball_sensor_figures(rawFile, label, freqs, fs, cfg, pdfDir, maxPlotFreq);
        end

        rpmVals(idx) = rpmValue;
        rmsVals(idx) = sqrt(mean(signal.^2));
        crestVals(idx) = max(abs(signal)) / max(rmsVals(idx), eps);
        kurtVals(idx) = compute_kurtosis(signal);
        bandEnergyVals(idx) = compute_envelope_band_energy(f1, spec1, targetFreq, bandHalfWidth);
    end

    metricsTable = table(string(labels)', rpmVals, rmsVals, crestVals, kurtVals, bandEnergyVals, ...
        'VariableNames', {'Condition','RPM','RMS','CrestFactor','Kurtosis','EnvelopeBandEnergy'});

    disp(metricsTable);
    fprintf('Diagnostic figures stored in %s\n', cfg.results_dir);
    fprintf('Diagnostic PDF figures stored in %s\n', pdfDir);
end

function value = read_field(structure, fieldName, defaultValue)
    if isstruct(structure) && isfield(structure, fieldName)
        value = structure.(fieldName);
        if isempty(value)
            value = defaultValue;
        end
    else
        value = defaultValue;
    end
end

function freqs = compute_fault_frequencies(rpm)
    shaftFreq = rpm / 60;
    n = 9;
    Bd = 7.94e-3;
    Pd = 39e-3;
    theta = 0;

    freqs = struct();
    freqs.shaft = shaftFreq;
    freqs.FTF  = 0.5 * shaftFreq * (1 - (Bd/Pd) * cos(theta));
    freqs.BPFO = (n / 2) * shaftFreq * (1 - (Bd/Pd) * cos(theta));
    freqs.BPFI = (n / 2) * shaftFreq * (1 + (Bd/Pd) * cos(theta));
    freqs.BSF  = (Pd / Bd)  * shaftFreq * (1 - ((Bd/Pd) * cos(theta))^2);
end

function fig = plot_method_comparison(f1, spec1, f2, spec2, label, maxFreq)
    valid1 = f1 >= 10 & f1 <= maxFreq;
    valid2 = f2 >= 10 & f2 <= maxFreq;

    fig = figure('Color', 'w');
    subplot(2,1,1);
    plot(f1(valid1), spec1(valid1), 'LineWidth', 1.1);
    grid on;
    xlim([10 maxFreq]);
    ylabel('Amplitude Normalizada');
    title('Method 1 – Squared Envelope Spectrum');

    subplot(2,1,2);
    plot(f2(valid2), spec2(valid2), 'LineWidth', 1.1);
    grid on;
    xlim([10 maxFreq]);
    xlabel('Frequência (Hz)');
    ylabel('Amplitude Normalizada');
    title('Method 2 – Cepstrum Prewhitening');

    sgtitle(label);
end

function fig = plot_fault_markers(f, spectrum, freqs, targetName, label, maxFreq, varargin)
    options = struct('MinFreq', 10, 'HarmonicStart', 1, 'NumHarmonics', 2, 'SidebandCount', 2);
    for idx = 1:2:numel(varargin)
        options.(varargin{idx}) = varargin{idx + 1};
    end
    minFreq = options.MinFreq;
    harmonicStart = options.HarmonicStart;
    numHarmonics = options.NumHarmonics;
    sidebandCount = max(0, options.SidebandCount);

    valid = f >= minFreq & f <= maxFreq;
    fig = figure('Color', 'w');
    plot(f(valid), spectrum(valid), 'LineWidth', 1.1);
    grid on;
    hold on;
    xlim([minFreq maxFreq]);
    xlabel('Frequência (Hz)');
    ylabel('Amplitude Normalizada');
    title(sprintf('Envelope Spectrum + Fault Markers (%s)', label));

    markerNames = {'FTF','BPFO','BPFI','BSF'};
    palette = lines(numel(markerNames));
    legendHandles = gobjects(0, 1);
    legendLabels = {};
    harmonicHandles = gobjects(0, 1);
    harmonicLabels = {};
    haveHarmonicLegend = false;
    targetHandle = [];
    targetFreq = freqs.(targetName);
    if targetFreq >= minFreq && targetFreq <= maxFreq
        targetHandle = xline(targetFreq, '-', 'Color', [0.85 0.33 0.1], 'LineWidth', 1.2, 'DisplayName', targetName);
    end

    harmonicSeq = [];
    if numHarmonics > 0 && targetFreq > 0
        if harmonicStart <= 1
            startVal = 2;
        else
            startVal = harmonicStart;
        end
        endVal = startVal + numHarmonics - 1;
        harmonicSeq = startVal:endVal;
        for hIdx = 1:numel(harmonicSeq)
            harmonic = harmonicSeq(hIdx);
            freq = harmonic * targetFreq;
            if freq >= minFreq && freq <= maxFreq
                hLine = xline(freq, '--', 'Color', [0.85 0.33 0.1], 'LineWidth', 1.0);
                if harmonicStart >= 18
                    labelH = sprintf('%dx%s', harmonic, targetName);
                    hLine.DisplayName = labelH;
                    harmonicHandles(end + 1, 1) = hLine; %#ok<AGROW>
                    harmonicLabels{end + 1, 1} = labelH; %#ok<AGROW>
                    haveHarmonicLegend = true;
                else
                    hLine.HandleVisibility = 'off';
                end
            end
        end
    end

    shaftFreq = freqs.shaft;
    if shaftFreq > 0 && ~isempty(harmonicSeq) && sidebandCount > 0
        harmonicList = harmonicSeq;
        if ~isempty(targetHandle)
            harmonicList = unique([1, harmonicList]);
        end
        for k = 1:numel(harmonicList)
            baseFreq = harmonicList(k) * targetFreq;
            for sb = 1:sidebandCount
                freqPlus = baseFreq + sb * shaftFreq;
                freqMinus = baseFreq - sb * shaftFreq;
                if freqPlus >= minFreq && freqPlus <= maxFreq
                    xline(freqPlus, ':', 'Color', [0.2 0.2 0.2], 'LineWidth', 0.8, 'HandleVisibility', 'off');
                end
                if freqMinus >= minFreq && freqMinus <= maxFreq
                    xline(freqMinus, ':', 'Color', [0.2 0.2 0.2], 'LineWidth', 0.8, 'HandleVisibility', 'off');
                end
            end
        end
    end

    handles = legendHandles;
    labels = legendLabels;
    if ~isempty(targetHandle)
        handles = [targetHandle; handles];
        labels = [{targetName}; labels];
    end
    if ~isempty(harmonicHandles)
        handles = [handles; harmonicHandles];
        labels = [labels; harmonicLabels];
    end
    if ~isempty(handles)
        legend(handles, labels, 'Location', 'northeast');
    end
    hold off;
end

function energy = compute_envelope_band_energy(f, spectrum, centerFreq, halfWidth)
    if centerFreq <= 10
        energy = 0;
        return;
    end
    lowBound = max(10, centerFreq - halfWidth);
    highBound = centerFreq + halfWidth;
    mask = (f >= lowBound) & (f <= highBound);
    if ~any(mask)
        energy = 0;
        return;
    end
    energy = trapz(f(mask), spectrum(mask));
end

function [Senv, f] = method1_envelope(x, fs)
    analytic = hilbert(x);
    envSquared = abs(analytic).^2;
    Nfft = 2^nextpow2(numel(envSquared));
    spectrum = abs(fft(envSquared, Nfft)).^2;
    halfIdx = floor(Nfft/2);
    Senv = spectrum(1:halfIdx);
    f = (0:halfIdx-1) * (fs / Nfft);
    maxVal = max(Senv);
    if maxVal > 0
        Senv = Senv / maxVal;
    end
end

function [Senv, f] = method2_cepstrum(x, fs)
    N = numel(x);
    X = fft(x);
    amp = abs(X) + eps;
    cep = real(ifft(log(amp)));
    L = min(30, floor(N/2) - 1);
    cepLift = cep;
    if L > 0
        cepLift(1:L+1) = 0;
        cepLift(end-L+1:end) = 0;
    end
    prewhiteAmp = exp(fft(cepLift));
    x_pw = real(ifft(prewhiteAmp .* exp(1i * angle(X))));
    [Senv, f] = method1_envelope(x_pw, fs);
end

function k = compute_kurtosis(x)
    x = x(:);
    mu = mean(x);
    sigma = std(x);
    if sigma == 0
        k = NaN;
        return;
    end
    k = mean(((x - mu) / sigma).^4);
end

function [pxx, f] = compute_psd(x, fs)
    x = x(:);
    if isempty(x)
        pxx = [];
        f = [];
        return;
    end
    windowLength = min(4096, numel(x));
    if windowLength < 256
        windowLength = numel(x);
    end
    window = hamming(windowLength);
    noverlap = floor(windowLength/2);
    nfft = max(2048, 2^nextpow2(windowLength));
    [pxx, f] = pwelch(x, window, noverlap, nfft, fs);
end

function fig = plot_psd_comparison(baseF, basePSD, sampleF, samplePSD, label, maxFreq)
    validBase = baseF >= 10 & baseF <= maxFreq;
    validSample = sampleF >= 10 & sampleF <= maxFreq;

    fig = figure('Color', 'w');
    plot(sampleF(validSample), 10*log10(samplePSD(validSample)), 'LineWidth', 1.2, 'DisplayName', label);
    hold on;
    plot(baseF(validBase), 10*log10(basePSD(validBase)), 'LineWidth', 1.2, 'DisplayName', 'Baseline');
    grid on;
    xlabel('Frequência (Hz)');
    ylabel('PSD (dB/Hz)');
    xlim([10 maxFreq]);
    legend('Location', 'northeast');
    title(sprintf('PSD Comparativo – %s', label));
end

function create_ball_sensor_figures(rawFile, label, freqs, fs, cfg, pdfDir, maxFreq)
    sensors = load_ball_sensors(rawFile, cfg.raw_dir);
    order = {'DE','FE','BA'};
    spectra = struct();

    for i = 1:numel(order)
        name = order{i};
        if isfield(sensors, name)
            sig = normalize_signal(sensors.(name));
            [spec, f] = method1_envelope(sig, fs);
            spectra.(name) = struct('f', f, 'spec', spec);
        end
    end

    baseName = sprintf('%s_ball_sensors', rawFile(1:end-4));
    figAll = plot_ball_triple(spectra, order, label, freqs, 'BSF', maxFreq);
    saveas(figAll, fullfile(cfg.results_dir, [baseName '_all.png']));
    exportgraphics(figAll, fullfile(pdfDir, [baseName '_all.pdf']), 'ContentType', 'vector');

    if isfield(spectra, 'BA')
        figBA = plot_fault_markers(spectra.BA.f, spectra.BA.spec, freqs, 'BSF', ...
            sprintf('%s – Base Accelerometer', label), maxFreq);
        saveas(figBA, fullfile(cfg.results_dir, [baseName '_ba.png']));
        exportgraphics(figBA, fullfile(pdfDir, [baseName '_ba.pdf']), 'ContentType', 'vector');

        zoomName = sprintf('%s_ball_zoom', rawFile(1:end-4));
        figBAHigh = plot_fault_markers(spectra.BA.f, spectra.BA.spec, freqs, 'BSF', ...
            sprintf('%s – BA (2500-4500 Hz)', label), 4500, ...
            'MinFreq', 2500, 'HarmonicStart', 20, 'NumHarmonics', 1, 'SidebandCount', 6);
        saveas(figBAHigh, fullfile(cfg.results_dir, [zoomName '.png']));
        exportgraphics(figBAHigh, fullfile(pdfDir, [zoomName '.pdf']), 'ContentType', 'vector');
    end
end

function sensors = load_ball_sensors(matFile, rawDir)
    data = load(fullfile(rawDir, matFile));
    sensors = struct();
    suffixes = {'DE_time','FE_time','BA_time'};
    names = {'DE','FE','BA'};
    for i = 1:numel(suffixes)
        channel = extract_channel(data, suffixes{i});
        if ~isempty(channel)
            sensors.(names{i}) = channel(:);
        end
    end
end

function channel = extract_channel(dataStruct, suffix)
    fields = fieldnames(dataStruct);
    idx = contains(fields, suffix);
    if any(idx)
        channel = dataStruct.(fields{find(idx,1)});
    else
        channel = [];
    end
end

function fig = plot_ball_triple(spectra, order, label, freqs, targetName, maxFreq)
    fig = figure('Color', 'w');
    tiledlayout(3, 1, 'TileSpacing', 'compact');
    for i = 1:numel(order)
        ax = nexttile;
        if isfield(spectra, order{i})
            f = spectra.(order{i}).f;
            spec = spectra.(order{i}).spec;
            valid = f >= 10 & f <= maxFreq;
            plot(ax, f(valid), spec(valid), 'LineWidth', 1.1);
            hold(ax, 'on');
            add_harmonic_markers(ax, freqs, targetName, [10 maxFreq], 1, 2);
        else
            plot(ax, NaN, NaN);
        end
        grid(ax, 'on');
        xlim(ax, [10 maxFreq]);
        ylabel(ax, order{i});
        if i == numel(order)
            xlabel(ax, 'Frequência (Hz)');
        end
        hold(ax, 'off');
    end
    sgtitle(sprintf('%s – Envelope Spectrum (DE/FE/BA)', label));
end

function add_harmonic_markers(ax, freqs, targetName, freqRange, harmonicStart, numHarmonics)
    if ~isfield(freqs, targetName)
        return;
    end
    if nargin < 4 || isempty(freqRange)
        freqRange = [0, inf];
    end
    if nargin < 5 || isempty(harmonicStart)
        harmonicStart = 1;
    end
    if nargin < 6 || isempty(numHarmonics)
        numHarmonics = 2;
    end

    minFreq = freqRange(1);
    maxFreq = freqRange(2);
    targetFreq = freqs.(targetName);
    color = [0.85 0.33 0.1];

    if targetFreq >= minFreq && targetFreq <= maxFreq && harmonicStart <= 1
        xline(ax, targetFreq, '-', 'Color', color, 'LineWidth', 1.0, 'HandleVisibility', 'off');
    end
    if numHarmonics <= 0 || targetFreq <= 0
        return;
    end

    if harmonicStart <= 1
        startVal = 2;
    else
        startVal = harmonicStart;
    end
    endVal = startVal + numHarmonics - 1;

    for harmonic = startVal:endVal
        freq = harmonic * targetFreq;
        if freq >= minFreq && freq <= maxFreq
            xline(ax, freq, '--', 'Color', color, 'LineWidth', 1.0, 'HandleVisibility', 'off');
        end
    end
end

function signal = normalize_signal(signal)
    signal = signal(:) - mean(signal);
    sigma = std(signal);
    if sigma > 0
        signal = signal / sigma;
    end
end