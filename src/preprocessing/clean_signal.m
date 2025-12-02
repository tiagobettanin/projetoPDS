function signal_out = clean_signal(signal_in)
    % CLEAN_SIGNAL Realiza o pré-processamento básico
    % 1. Remove nível DC (viés do sensor)
    % 2. Normaliza pelo Z-Score (média 0, desvio padrão 1)
    
    % Remover média (DC Offset)
    s_no_dc = signal_in - mean(signal_in);
    
    % Normalização Z-Score
    % Coloca o sinal em unidades de "desvio padrão".
    % Isso permite comparar sinais de cargas diferentes sem distorção.
    signal_out = (s_no_dc) / std(s_no_dc);
end