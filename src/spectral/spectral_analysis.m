addpath('..');
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
rpm = 1796; % ou 1797
fs = cfg.fs;
freq_rot = rpm/60;
FR = freq_rot;

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

disp(['BPFO: ', num2str(bpfo), ' Hz']);
disp(['BPFI: ', num2str(bpfi), ' Hz']);
disp(['BSF: ', num2str(bsf), ' Hz']);
disp(['FTF: ', num2str(ftf), ' Hz']);

titulos = {"Baseline", "Inner Light", "Ball Light", "Outer Light", "Inner Severe", "Ball Severe", "Outter Severe"};


max_freq = max([bpfo, bpfi, bsf, ftf]);
suggested_window_length = round(fs / max_freq);

suggested_window_length = 2^nextpow2(suggested_window_length);
suggested_noverlap = floor(suggested_window_length / 2);


% parametros metodo de welch

nfft = 12000;
windowLength = 1024;
% fs/windowLenght = x Hz x peqeuno deixa mais visivel picos proximos
% olhar o grafico do gabriel com 1024
window = hamming(windowLength);
noverlap = floor(windowLength/2);

window_rect = rectwin(windowLength);





fds = {0, bpfi, bsf, bpfo, bpfi, bsf, bpfo};


%% k = 1 -> fft
%% k = 2 -> psd welch hamming
%% k = 3 -> psd comparando hamming e retangular
k = 4;
for k = 1:4

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
            [pxx_rect, f_rect] = pwelch(x, window_rect, noverlap, nfft, fs);
            [pxx_ham,  f_ham]  = pwelch(x, hamming(windowLength), noverlap, nfft, fs);

            psd_comparativo(pxx_rect, f_rect, pxx_ham, f_ham, titulos{i});
        end
        if k == 4
            x = data.(key).clean_sig; 
            b = data.('baseline').clean_sig;
            [b_ham,  f_b]  = pwelch(b, hamming(windowLength), noverlap, nfft, fs);
            [pxx_ham,  f_ham]  = pwelch(x, hamming(windowLength), noverlap, nfft, fs);
            minLen = min(length(b_ham), length(pxx_ham));
            b_ham   = b_ham(1:minLen);
            pxx_ham = pxx_ham(1:minLen);
            
            % RMSE
            rmse = sqrt(mean((b_ham - pxx_ham).^2));
            
            disp([key ' ' num2str(rmse)]);
            baseline_comparativo(b_ham, f_b, pxx_ham, f_ham, titulos{i});
        end
    end
end
