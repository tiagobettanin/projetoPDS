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
