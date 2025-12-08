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
