function cfg = config()
    % CONFIG Configurações Globais do Projeto
    % Usa caminhos absolutos para evitar erros de "arquivo não encontrado"

    % 1. Descobre o caminho absoluto da pasta src
    path_src = fileparts(mfilename('fullpath'));
    
    % 2. Descobre a raiz do projeto (um nível acima de src)
    path_root = fileparts(path_src);
    
    % Definições Gerais - 12kHz pois é o padrão dos dados CWRU
    cfg.fs = 12000;
    
    % Informações do rolamento 
    cfg.bearing.model = '6205-2RS JEM';
        
    % 3. Define Caminhos Absolutos
    cfg.raw_dir       = fullfile(path_root, 'data', 'raw');
    cfg.processed_dir = fullfile(path_root, 'data', 'processed');
    cfg.results_dir   = fullfile(path_root, 'results', 'figures');

    % --- Mapeamento dos Arquivos ---
    
    % Saudável
    cfg.files.baseline = '97.mat';
    
    % Falhas Leves (0.007")
    cfg.files.inner_light = '105.mat';
    cfg.files.ball_light  = '118.mat';
    cfg.files.outer_light = '130.mat';
    
    % Falhas Graves (0.021")
    cfg.files.inner_severe = '209.mat';
    cfg.files.ball_severe  = '222.mat';
    cfg.files.outer_severe = '234.mat';
end