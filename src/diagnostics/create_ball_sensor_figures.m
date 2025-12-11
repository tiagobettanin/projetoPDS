function create_ball_sensor_figures(rawFile, label, freqs, fs, cfg, pdfDir, maxFreq)
    deSignal = load_drive_end_signal(rawFile, cfg.raw_dir);
    if isempty(deSignal)
        warning('Canal DE não encontrado para %s.', rawFile);
        return;
    end

    sig = normalize_signal(deSignal);
    [spec, f] = method1_envelope(sig, fs);

    figDE = plot_fault_markers(f, spec, freqs, 'BSF', ...
        sprintf('%s', label), maxFreq);
    saveas(figDE, fullfile(cfg.results_dir, sprintf('%s_de.png', rawFile(1:end-4))));
    exportgraphics(figDE, fullfile(pdfDir, sprintf('%s_de.pdf', rawFile(1:end-4))), 'ContentType', 'vector');

    figDEHigh = plot_fault_markers(f, spec, freqs, 'BSF', ...
        sprintf('%s', label), 4500, ...
        'MinFreq', 2500, 'HarmonicStart', 18, 'NumHarmonics', 10, 'SidebandCount', 0);
    saveas(figDEHigh, fullfile(cfg.results_dir, sprintf('%s_de_zoom.png', rawFile(1:end-4))));
    exportgraphics(figDEHigh, fullfile(pdfDir, sprintf('%s_de_zoom.pdf', rawFile(1:end-4))), 'ContentType', 'vector');
end

function signal = load_drive_end_signal(matFile, rawDir)
    data = load(fullfile(rawDir, matFile));
    fields = fieldnames(data);
    idx = contains(fields, 'DE_time');
    if any(idx)
        signal = data.(fields{find(idx, 1)})(:);
    else
        signal = [];
    end
end

function signal = normalize_signal(signal)
    signal = signal(:) - mean(signal);
    sigma = std(signal);
    if sigma > 0
        signal = signal / sigma;
    end
end
