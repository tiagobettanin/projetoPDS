clc; clear; close all;

% Garante que toda a árvore de src esteja no path
addpath(genpath('src'));

disp('===================================================');
disp(' MAIN DO PROJETO PDS - PIPELINE COMPLETO ');
disp('===================================================');

try
    % ----------------- PARTE 1: PRÉ-PROCESSAMENTO -----------------
    disp(' ');
    disp('>>> [1/3] Executando pré-processamento (mainP1)...');
    run(fullfile('src','preprocessing','mainP1.m'));

    % ----------------- PARTE 2: DIAGNÓSTICO -----------------
    disp(' ');
    disp('>>> [2/3] Executando métricas de diagnóstico...');
    diagnostics_metrics();

    % ----------------- PARTE 3: ANÁLISE ESPECTRAL -----------------
    disp(' ');
    disp('>>> [3/3] Executando análise espectral...');
    run(fullfile('src','spectral','spectral_analysis.m'));

    disp(' ');
    disp('===================================================');
    disp(' PIPELINE COMPLETO FINALIZADO COM SUCESSO ');
    disp('===================================================');
catch ME
    disp(' ');
    disp('===================================================');
    disp(' ERRO NO MAIN DO PROJETO:');
    disp(ME.message);
    disp('===================================================');
    rethrow(ME);
end
