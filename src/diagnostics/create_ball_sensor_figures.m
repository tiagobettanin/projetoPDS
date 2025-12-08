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
