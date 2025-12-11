function [pxx, f] = psd_we(x, window, noverlap, nfft, fs, fd, tipo_janela, texto)

[pxx, f] = pwelch(x, window, noverlap, nfft, fs);
figure;
plot(f, 10*log10(pxx));
xlabel('Frequência (Hz)');
ylabel('PSD (dB/Hz)');
titulo = ['Método de Welch' tipo_janela, texto];
    if fd ~= 0
        xline(fd, '--r', 'Frequencia de defeito'); 
    end
title(titulo);
grid on;


end