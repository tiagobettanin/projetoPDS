function [Senv, f] = method2_cepstrum(x, fs)
    N = numel(x);
    X = fft(x);
    amp = abs(X) + eps;
    cep = real(ifft(log(amp)));
    L = min(30, floor(N/2) - 1);
    cepLift = cep;
    if L > 0
        cepLift(1:L+1) = 0;
        cepLift(end-L+1:end) = 0;
    end
    prewhiteAmp = exp(fft(cepLift));
    x_pw = real(ifft(prewhiteAmp .* exp(1i * angle(X))));
    [Senv, f] = method1_envelope(x_pw, fs);
end
