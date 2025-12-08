function diagnostics_metrics()
    cfg = config();
    if ~exist(cfg.results_dir, 'dir'); mkdir(cfg.results_dir); end
    resultsRoot = fileparts(cfg.results_dir);
    pdfDir = fullfile(resultsRoot, 'figures_pdf');
    if ~exist(pdfDir, 'dir'); mkdir(pdfDir); end

    keys = {'baseline','inner_light','ball_light','outer_light','inner_severe','ball_severe','outer_severe'};
    labels = {"Baseline","Inner Light","Ball Light","Outer Light","Inner Severe","Ball Severe","Outer Severe"};
    targets = {'FTF','BPFI','BSF','BPFO','BPFI','BSF','BPFO'};
    maxPlotFreq = 600;
    bandHalfWidth = 5;
    rpmFallback = 1797;

    baselinePath = fullfile(cfg.processed_dir, 'baseline.mat');
    if ~isfile(baselinePath); error('Arquivo baseline processado não encontrado: %s', baselinePath); end
    baselineSample = load(baselinePath);
    baselineSig = baselineSample.clean_sig(:);
    baselineFs = read_field(baselineSample, 'fs', cfg.fs);
    [baselinePSD, baselineFreq] = compute_psd(baselineSig, baselineFs);

    rpmVals = zeros(numel(keys),1);
    rmsVals = zeros(numel(keys),1);
    crestVals = zeros(numel(keys),1);
    kurtVals = zeros(numel(keys),1);
    bandEnergyVals = zeros(numel(keys),1);

    for idx = 1:numel(keys)
        key = keys{idx};
        label = labels{idx};
        targetName = targets{idx};

        samplePath = fullfile(cfg.processed_dir, [key '.mat']);
        if ~isfile(samplePath); error('Arquivo processado não encontrado: %s', samplePath); end
        sample = load(samplePath);
        if ~isfield(sample, 'clean_sig'); error('Arquivo %s não contém clean_sig.', samplePath); end

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

        figMarkers = plot_fault_markers(f1, spec1, freqs, targetName, label, maxPlotFreq);
        saveas(figMarkers, fullfile(cfg.results_dir, sprintf('%s_markers_%s.png', key, lower(targetName))));
        exportgraphics(figMarkers, fullfile(pdfDir, sprintf('%s_markers_%s.pdf', key, lower(targetName))), 'ContentType', 'vector');

        if contains(key, 'ball')
            create_ball_sensor_figures(cfg.files.(key), label, freqs, fs, cfg, pdfDir, maxPlotFreq);
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