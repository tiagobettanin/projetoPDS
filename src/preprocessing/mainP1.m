% Função:
% 1. Verifica integridade dos arquivos Raw.
% 2. Executa o pipeline ETL (Limpeza e Salvamento).
% 3. Gera gráficos de validação visual.

clear; clc; close all;
format compact;

% 1. Configuração de Caminhos
% Adiciona a pasta src (um nível acima) para pegar o config.m
addpath('..'); 

try
    cfg = config();
    disp('===================================================');
    disp(' INICIANDO PIPELINE DE DADOS ');
    disp('===================================================');
    disp([' Raiz do Projeto: ', fileparts(fileparts(cfg.raw_dir))]);

    %% ETAPA 1: VERIFICAÇÃO DE ARQUIVOS RAW
    disp(' ');
    disp('🔍 [1/3] Verificando arquivos brutos (Raw Data)...');
    
    required_files = { ...
        cfg.files.baseline, ...
        cfg.files.inner_light, cfg.files.ball_light, cfg.files.outer_light, ...
        cfg.files.inner_severe, cfg.files.ball_severe, cfg.files.outer_severe ...
    };
    
    missing = false;
    for i = 1:length(required_files)
        fname = required_files{i};
        fpath = fullfile(cfg.raw_dir, fname);
        if ~isfile(fpath)
            fprintf('   ❌ FALTANDO: %s\n', fname);
            missing = true;
        end
    end
    
    if missing
        error('Parando execução. Faltam arquivos na pasta data/raw/.');
    else
        disp('   ✅ Todos os 7 arquivos raw foram encontrados.');
    end

    %% ETAPA 2: EXECUÇÃO DO ETL (EXTRACT, TRANSFORM, LOAD)
    disp(' ');
    disp('⚙️ [2/3] Rodando ETL (Gerando arquivos .mat limpos)...');
    
    % Chama o script run_etl.m que já criamos
    run('run_etl.m'); 
    
    % Confere se gerou os arquivos
    processed_files = dir(fullfile(cfg.processed_dir, '*.mat'));
    fprintf('   ✅ Arquivos processados disponíveis: %d\n', length(processed_files));

    %% ETAPA 3: GERAÇÃO DE FIGURAS
    disp(' ');
    disp('📊 [3/3] Gerando Gráficos de Controle...');
    
    % Chama o script de plotagem
    run('plot_time_comparison.m');
    
    disp('   ✅ Figura time_domain_comparison.png gerada com sucesso.');

    %% CONCLUSÃO
    disp(' ');
    disp('===================================================');
    disp('✅ PARTE 1 FINALIZADA! O AMBIENTE ESTÁ PRONTO.');
    disp('---------------------------------------------------');

catch ME
    disp(' ');
    disp('❌ ERRO CRÍTICO NO PIPELINE:');
    disp(ME.message);
end