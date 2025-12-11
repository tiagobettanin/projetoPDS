% ETL: Extract (Raw), Transform (Clean), Load (Save Processed)
addpath('..'); % Acesso ao config.m

cfg = config();
disp('🚀 Iniciando Pipeline de Pré-processamento (ETL)...');

% Lista de arquivos para processar (Baseado no config.m)
% Estrutura: { 'Nome_de_Saida', 'Nome_Arquivo_Raw' }
tasks = {
    'baseline',     cfg.files.baseline;
    'inner_light',  cfg.files.inner_light;
    'ball_light',   cfg.files.ball_light;
    'outer_light',  cfg.files.outer_light;
    'inner_severe', cfg.files.inner_severe;
    'ball_severe',  cfg.files.ball_severe;
    'outer_severe', cfg.files.outer_severe
};


% Loop de Processamento
for i = 1:size(tasks, 1)
    key_name = tasks{i, 1};  % Ex: 'inner_light'
    raw_file = tasks{i, 2};  % Ex: '105.mat'
    
    fprintf('⚡ Processando: %s (%s)... ', key_name, raw_file);
    
    % 1. Carregar (Extract)
    try
        [raw_sig, rpm] = load_data(raw_file);
        
        % 2. Limpar (Transform)
        clean_sig = clean_signal(raw_sig);
        
        % 3. Salvar (Load)
        % Salva com o nome da chave (ex: inner_light.mat) para facilitar pro Membro 2
        save_path = fullfile(cfg.processed_dir, [key_name, '.mat']);
        
        % Salvamos apenas as variáveis úteis
        save(save_path, 'clean_sig', 'rpm');
        
        fprintf('✅ Salvo em: %s\n', [key_name, '.mat']);
        
    catch ME
        fprintf('❌ ERRO: %s\n', ME.message);
    end
end

disp('------------------------------------------------');
disp(' ETL Concluído! Os arquivos limpos estão na pasta data/processed/.');
disp('------------------------------------------------');