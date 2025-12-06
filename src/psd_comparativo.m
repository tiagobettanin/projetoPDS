function [] = psd_comparativo(pxx_rect, f_rect, pxx_ham, f_ham, texto)

figure;
plot(f_rect, 10*log10(pxx_rect), 'LineWidth', 1.2); hold on;
plot(f_ham,  10*log10(pxx_ham),  'LineWidth', 1.2);
legend('Janela Retangular', 'Janela Hamming');
xlabel('Frequência (Hz)');
ylabel('PSD (dB/Hz)');
titulo = ['Comparativo de Janelas - Retangular vs Hamming ' texto];
title(titulo);
grid on;

end