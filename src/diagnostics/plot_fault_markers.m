function fig = plot_fault_markers(f, spectrum, freqs, targetName, label, maxFreq, varargin)
    options = struct('MinFreq', 10, 'HarmonicStart', 1, 'NumHarmonics', 2, 'SidebandCount', 2);
    for idx = 1:2:numel(varargin)
        name = varargin{idx};
        value = varargin{idx + 1};
        if isfield(options, name)
            options.(name) = value;
        else
            error('Parâmetro desconhecido: %s', name);
        end
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
    markerColors = struct( ...
        'FTF',  [0.17 0.63 0.17], ...
        'BPFO', [0.85 0.33 0.10], ...
        'BPFI', [0.93 0.69 0.13], ...
        'BSF',  [0.49 0.18 0.56]);

    legendHandles = gobjects(0, 1);
    legendLabels = {};

    targetColor = markerColors.(targetName);
    targetHandle = gobjects(0);
    targetFreq = freqs.(targetName);
    if targetFreq >= minFreq && targetFreq <= maxFreq
        targetHandle = xline(targetFreq, '-', 'Color', targetColor, 'LineWidth', 1.2, 'DisplayName', targetName);
    end

    harmonicHandles = gobjects(0, 1);
    harmonicLabels = {};
    harmonicFreqsPlotted = [];
    if numHarmonics > 0 && targetFreq > 0
        startVal = max(harmonicStart, 1);
        if startVal <= 1
            startVal = 2;
        end
        endVal = startVal + numHarmonics - 1;
        for harmonic = startVal:endVal
            freqH = harmonic * targetFreq;
            if freqH >= minFreq && freqH <= maxFreq
                h = xline(freqH, '--', 'Color', targetColor, 'LineWidth', 1.0);
                if harmonicStart >= 18
                    labelH = sprintf('%dx%s', harmonic, targetName);
                    h.DisplayName = labelH;
                    harmonicHandles(end + 1, 1) = h; %#ok<AGROW>
                    harmonicLabels{end + 1, 1} = labelH; %#ok<AGROW>
                else
                    h.HandleVisibility = 'off';
                end
                harmonicFreqsPlotted(end + 1) = freqH; %#ok<AGROW>
            end
        end
    end

    shaftFreq = freqs.shaft;
    if shaftFreq > 0 && sidebandCount > 0
        baseFreqs = harmonicFreqsPlotted;
        if ~isempty(targetHandle) && harmonicStart <= 1
            baseFreqs = [targetFreq, baseFreqs];
        end
        for baseFreq = baseFreqs
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
