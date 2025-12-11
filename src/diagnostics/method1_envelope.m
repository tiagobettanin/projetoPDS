%{
% Fundamentação teórica:
% 1) A transformada de Hilbert constrói o sinal analítico x_a(t) = x(t) + j·ℋ{x(t)},
%    cujo módulo A(t) = |x_a(t)| é a envoltória instantânea (amplitude lenta)
%    do sinal banda larga provocado por impactos em rolamentos.
% 2) A energia desses impactos modula uma portadora de alta frequência; ao elevar
%    A(t) ao quadrado obtém-se potência instantânea, equivalente a demodular um
%    sinal AM e destacar as componentes periódicas induzidas pelas falhas.
% 3) A FFT dessa potência revela, no domínio da frequência, picos em FTF/BPFI/BPFO/
%    BSF e seus harmônicos, permitindo identificar padrões de repetição dos
%    impactos mesmo quando o espectro bruto é dominado pela portadora.
% 4) A normalização final ajusta a escala para comparação entre condições.
%}
function [Senv, f] = method1_envelope(x, fs)
    analytic = hilbert(x);              % sinal analítico: x(t) + j·ℋ{x(t)}
    envSquared = abs(analytic).^2;      % potência instantânea (envoltória demodulada)
    Nfft = 2^nextpow2(numel(envSquared));
    spectrum = abs(fft(envSquared, Nfft)).^2; % espectro da potência da envoltória
    halfIdx = floor(Nfft/2);
    Senv = spectrum(1:halfIdx);
    f = (0:halfIdx-1) * (fs / Nfft);
    maxVal = max(Senv);
    if maxVal > 0
        Senv = Senv / maxVal;           % normaliza para facilitar comparação relativa
    end
end
