function [pxx, f] = compute_psd(x, fs)
    x = x(:);
    if isempty(x)
        pxx = [];
        f = [];
        return;
    end
    windowLength = min(4096, numel(x));
    if windowLength < 256
        windowLength = numel(x);
    end
    window = hamming(windowLength);
    noverlap = floor(windowLength/2);
    nfft = max(2048, 2^nextpow2(windowLength));
    [pxx, f] = pwelch(x, window, noverlap, nfft, fs);
end
