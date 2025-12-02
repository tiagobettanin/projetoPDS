clear; clc; close all;

% Adiciona caminhos
addpath('../'); % Para pegar o config.m
addpath('.');   % Para pegar load_data e clean_signal

cfg = config();

% 1. Carregar um Saudável e um com Defeito (ex: Inner Race)
[raw_normal, ~] = load_data(cfg.files.baseline);
[raw_fault, ~]  = load_data(cfg.files.inner_light);

% 2. Limpar os sinais
sig_normal = clean_signal(raw_normal);
sig_fault  = clean_signal(raw_fault);

% 3. Recortar apenas um pedacinho (0.05 segundos) para visualização, se plotar tudo, vira uma mancha azul sólida.
fs = cfg.fs;
t = (0:length(sig_normal)-1) / fs;
janela_tempo = 0.1; % Ver apenas 0.1 segundos
n_samples = round(janela_tempo * fs);

% Recorte
t_zoom = t(1:n_samples);
y_normal = sig_normal(1:n_samples);
y_fault  = sig_fault(1:n_samples);

% 4. Gerar a Figura
figure('Color', 'w', 'Position', [100, 100, 800, 400]);

subplot(2, 1, 1);
plot(t_zoom, y_normal, 'b');
title('Motor Saudável (Domínio do Tempo)');
ylabel('Amplitude (Norm.)');
grid on; xlim([0, janela_tempo]);

subplot(2, 1, 2);
plot(t_zoom, y_fault, 'r');
title('Falha na Pista Interna - 0.007" (Domínio do Tempo)');
xlabel('Tempo (s)');
ylabel('Amplitude (Norm.)');
grid on; xlim([0, janela_tempo]);

% Salvar automaticamente na pasta de resultados
save_path = fullfile(cfg.processed_dir, '..', '..', 'results', 'figures', 'time_domain_comparison.png');
saveas(gcf, save_path);

disp(['Gráfico salvo em: ', save_path]);