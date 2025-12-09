clear; clc; close all;

% Adiciona caminhos
addpath('../'); % Para pegar o config.m
addpath('.');   % Para pegar load_data e clean_signal

cfg = config();
disp('📊 Gerando Comparativos no Domínio do Tempo...');

%% 1. PREPARAÇÃO DO BASELINE (SAUDÁVEL)
% Carregamos o saudável apenas uma vez, pois ele vai em todos os gráficos
disp('   Carregando Baseline...');
[raw_normal, ~] = load_data(cfg.files.baseline);
sig_normal = clean_signal(raw_normal);

% Configuração do Eixo do Tempo (Recorte de 0.1s)
fs = cfg.fs;
janela_tempo = 0.1;
n_samples = round(janela_tempo * fs);

% Vetor de tempo e sinal saudável recortados
t_zoom = (0:n_samples-1) / fs;
y_normal = sig_normal(1:n_samples);

%% 2. DEFINIÇÃO DOS CENÁRIOS DE FALHA
% Lista de: { 'Nome_Arquivo_Saida', 'Arquivo_Mat', 'Titulo_Grafico' }
scenarios = {
    'comp_inner_light',  cfg.files.inner_light,  'Falha Pista Interna - Leve (0.007")';
    'comp_ball_light',   cfg.files.ball_light,   'Falha Esfera - Leve (0.007")';
    'comp_outer_light',  cfg.files.outer_light,  'Falha Pista Externa - Leve (0.007")';
    'comp_inner_severe', cfg.files.inner_severe, 'Falha Pista Interna - Grave (0.021")';
    'comp_ball_severe',  cfg.files.ball_severe,  'Falha Esfera - Grave (0.021")';
    'comp_outer_severe', cfg.files.outer_severe, 'Falha Pista Externa - Grave (0.021")';
};

% Pasta de destino
save_dir = fullfile(cfg.processed_dir, '..', '..', 'results', 'figures');
if ~exist(save_dir, 'dir'); mkdir(save_dir); end

%% 3. LOOP DE GERAÇÃO (PLOTA E SALVA)
for i = 1:size(scenarios, 1)
    % Extrai informações da linha atual
    fname_out = scenarios{i, 1};
    fname_mat = scenarios{i, 2};
    title_str = scenarios{i, 3};
    
    fprintf('   Processando: %s... ', title_str);
    
    % A. Carrega e Limpa a Falha
    try
        [raw_fault, ~] = load_data(fname_mat);
        sig_fault = clean_signal(raw_fault);
        
        % Recorte
        y_fault = sig_fault(1:n_samples);
        
        % B. Gera a Figura (invisível para ser mais rápido, se quiser ver mude 'off' para 'on')
        fig = figure('Color', 'w', 'Position', [100, 100, 800, 500], 'Visible', 'off');
        
        % Subplot 1: Saudável (Sempre igual)
        subplot(2, 1, 1);
        plot(t_zoom, y_normal, 'b');
        title('Motor Saudável (Domínio do Tempo)');
        ylabel('Amplitude (Norm.)');
        grid on; xlim([0, janela_tempo]);
        ylim([-4 4]); % Fixa escala para facilitar comparação visual
        
        % Subplot 2: Falha Atual
        subplot(2, 1, 2);
        plot(t_zoom, y_fault, 'r');
        title([title_str ' (Domínio do Tempo)']);
        xlabel('Tempo (s)');
        ylabel('Amplitude (Norm.)');
        grid on; xlim([0, janela_tempo]);
        ylim([-4 4]); % Fixa escala para mostrar se a amplitude aumentou
        
        % C. Salva
        save_path = fullfile(save_dir, [fname_out, '.png']);
        saveas(fig, save_path);
        close(fig); % Fecha a figura para não acumular na memória
        
        fprintf('✅ Salvo.\n');
        
    catch ME
        fprintf('❌ Erro: %s\n', ME.message);
    end
end

disp('------------------------------------------------');
disp(['🏁 Todos os gráficos foram salvos em: ' save_dir]);