cfg = config();
keys = {
    'baseline',    
    'inner_light',
    'ball_light',
    'outer_light',
    'inner_severe',
    'ball_severe',
    'outer_severe',
};

titulos = {"Baseline", "Inner Light", "Ball Light", "Outer Light", "Inner Severe", "Ball Severe", "Outter Severe"};

% parametros metodo de welch
fs = cfg.fs;
windowLength = 1024;
window = hamming(windowLength);
noverlap = floor(windowLength/2);
nfft = windowLength;


rpm = 1796; % ou 1797

freq_rot = rpm/60;


% "As falhas tipicas se manifestam-se ... e da rotação do eixo."
% BPFO (Ball Pass Frequency Outer race)
% BPFI (Ball Pass Frequency Inner race)
% BSF (Ball Spin Frequency)
% FTF (Fundamental Train Frequency)



% Calculate defect frequencies based on the running speed
bpfo = freq_rot * 3.5848;  % Ball Pass Frequency Outer race
bpfi = freq_rot * 5.4152;  % Ball Pass Frequency Inner race
bsf = freq_rot * 4.7135;   % Ball Spin Frequency // ball
ftf = freq_rot * 0.39828;    % Fundamental Train Frequency

% Display the calculated defect frequencies
disp(['BPFO: ', num2str(bpfo), ' Hz']);
disp(['BPFI: ', num2str(bpfi), ' Hz']);
disp(['BSF: ', num2str(bsf), ' Hz']);
disp(['FTF: ', num2str(ftf), ' Hz']);


fds = {0, bpfi, bsf, bpfo, bpfi, bsf, bpfo};


%% k = 1 -> fft
%% k = 2 -> psd welch hamming
%% k = 3 -> psd comparando hamming e retangular
for k = 1:3
    
    for i = 1:length(keys)
        key = keys{i};                         % e.g., 'baseline'
        filepath = fullfile(cfg.processed_dir, key);
    
        data.(key) = load(filepath);           % store in a struct
        if k == 1

            fft_unilateral(data.(key).clean_sig, fs, fds{i}, titulos{i});
        end
        if k == 2
            psd_we(data.(key).clean_sig, window, noverlap, nfft, fs, fds{i}, 'Janela Hamming', titulos{i});
        end
        if k == 3
            x = data.(key).clean_sig;  % Extract the clean signal for the current key
            [pxx_rect, f_rect] = pwelch(x, window_rect, noverlap, nfft, fs);  % Calculate PSD with rectangular window
            [pxx_ham,  f_ham]  = pwelch(x, hamming(windowLength), noverlap, nfft, fs);
        
            psd_comparativo(pxx_rect, f_rect, pxx_ham, f_ham, titulos{i});
        end
    end
end
