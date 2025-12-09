% filepath: c:\Users\gabri\Desktop\Facu\25-02\Processamento Digital de Sinais\projetoPDS\src\spectral\envelope_analysis.m
function result = envelope_analysis(x, fs, varargin)
signal = double(x(:));
p = inputParser;
p.FunctionName = 'envelope_analysis';
addParameter(p, 'Bandpass', [2000 10000], @(v)isnumeric(v) && numel(v) == 2);
addParameter(p, 'BandpassOrder', 4, @(n)isnumeric(n) && isscalar(n) && n >= 2);
addParameter(p, 'EnvelopeLowpass', 400, @(v)isempty(v) || (isnumeric(v) && isscalar(v) && v > 0));
addParameter(p, 'DecimateFactor', 1, @(v)isnumeric(v) && isscalar(v) && v >= 1);
addParameter(p, 'WindowLength', 2048, @(v)isnumeric(v) && isscalar(v) && v > 0);
addParameter(p, 'WindowType', 'hann', @is_charstr);
parse(p, varargin{:});
opts = p.Results;
opts.Bandpass = reshape(opts.Bandpass, 1, []);

[filtered, bpCoeffs] = apply_bandpass(signal, fs, opts.Bandpass, opts.BandpassOrder);

analytic = hilbert(filtered);
envelope = abs(analytic);
envelope = envelope - mean(envelope);

lpCoeffs = [];
envFs = fs;
if ~isempty(opts.EnvelopeLowpass) && opts.EnvelopeLowpass < fs / 2
    lpOrder = max(2, round(opts.BandpassOrder / 2));
    Wn = min(opts.EnvelopeLowpass / (fs / 2), 0.99);
    [b_lp, a_lp] = butter(lpOrder, Wn, 'low');
    envelope = filtfilt(b_lp, a_lp, envelope);
    lpCoeffs = struct('b', b_lp, 'a', a_lp, 'cutoff', opts.EnvelopeLowpass, 'order', lpOrder);
end

decFactor = max(1, round(opts.DecimateFactor));
if decFactor > 1
    envelope = decimate(envelope, decFactor);
    envFs = fs / decFactor;
end

windowLen = min(floor(opts.WindowLength), numel(envelope));
if windowLen < 2
    windowLen = numel(envelope);
end
window = select_window(opts.WindowType, windowLen);
noverlap = floor(0.5 * windowLen);
nfft = max(windowLen, 2^nextpow2(windowLen));

[psd, freq] = pwelch(envelope, window, noverlap, nfft, envFs, 'onesided');
psd = psd(:);
freq = freq(:);

result = struct( ...
    'filteredSignal', filtered, ...
    'envelope', envelope, ...
    'fs', envFs, ...
    'psd', psd, ...
    'freq', freq, ...
    'filters', struct('bandpass', bpCoeffs, 'lowpass', lpCoeffs), ...
    'params', opts);
end

function [filtered, coeffs] = apply_bandpass(x, fs, band, order)
filtered = x;
coeffs = [];
if isempty(band) || numel(band) ~= 2
    return;
end
band = sort(double(band(:))).';
nyquist = fs / 2;
band(1) = max(10, band(1));
band(2) = min(0.99 * nyquist, band(2));
if band(1) >= band(2)
    return;
end
ord = max(2, round(order));
[b, a] = butter(ord, band / nyquist, 'bandpass');
filtered = filtfilt(b, a, x);
coeffs = struct('b', b, 'a', a, 'band', band, 'order', ord);
end

function window = select_window(type, len)
if len <= 1
    window = ones(len, 1);
    return;
end
n = (0:len-1).';
switch lower(string(type))
    case {'hann','hanning'}
        window = 0.5 - 0.5*cos(2*pi*n/(len-1));
    case 'hamming'
        window = 0.54 - 0.46*cos(2*pi*n/(len-1));
    otherwise
        window = ones(len, 1);
end
end

function tf = is_charstr(val)
tf = (ischar(val) && isrow(val)) || (isstring(val) && isscalar(val));
end