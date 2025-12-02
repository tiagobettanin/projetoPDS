% src/preprocessing/load_data.m
function [signal, rpm] = load_data(filename)
    % LOAD_DATA Carrega um arquivo .mat do CWRU e extrai o sinal DE (Drive End)
    %
    % Entrada:
    %   filename - Nome do arquivo (ex: '97.mat') ou caminho completo
    %
    % Saída:
    %   signal - Vetor coluna com o sinal de vibração (DE_time)
    %   rpm    - Velocidade de rotação (se disponível)

    % 1. Carregar configurações para pegar o caminho correto
    cfg = config();
    
    % Verifica se o arquivo existe na pasta raw
    full_path = fullfile(cfg.raw_dir, filename);
    if ~isfile(full_path)
        error('Arquivo não encontrado: %s. Verifique a pasta data/raw/', full_path);
    end
    
    % 2. Carregar o arquivo .mat
    data_struct = load(full_path);
    
    % 3. Encontrar a variável correta
    % Os arquivos têm variáveis com nomes dinâmicos (X097_DE_time, X105_DE_time...)
    % Vamos procurar o campo que termina com "_DE_time"
    field_names = fieldnames(data_struct);
    
    signal = [];
    rpm = 0;
    
    for i = 1:length(field_names)
        name = field_names{i};
        
        % Procura pela vibração do Drive End (DE)
        if contains(name, 'DE_time')
            signal = data_struct.(name);
        end
        
        % Tenta pegar o RPM também
        if contains(name, 'RPM')
            rpm = data_struct.(name);
        end
    end
    
    if isempty(signal)
        error('Não foi possível encontrar a variável _DE_time no arquivo %s', filename);
    end
    
    % Garante que é vetor coluna
    signal = signal(:);
end