
function [saida, f] = fft_unilateral(entrada, fs, fd, texto)
    % fd = frequencia do defeito;
    % Supondo que x é seu sinal e fs é a taxa de amos   tragem
    N  = length(entrada);
    X  = fft(entrada);
    
    % FFT unilateral (somente parte positiva)
    saida = abs(X)/N;          
    saida = saida(1:N/2+1);
    saida(2:end-1) = 2*saida(2:end-1);
    
    % Vetor de frequências
    f = (0:(N/2)) * (fs/N);
    
    % Plot
    figure;
    plot(f, saida);
    if fd ~= 0
        xline(fd, '--r', 'Frequencia de defeito'); % Linha tracejada vermelha com rótulo
    end
    xlabel('Frequência (Hz)');
    ylabel('|X(f)|');
    titulo = ['FFT Unilateral ' texto];
    title(titulo);
    grid on;

end