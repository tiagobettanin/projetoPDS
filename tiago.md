## 1. Visão Geral e Responsabilidades

Este documento detalha as atividades realizadas referentes à minha parte. O objetivo desta etapa foi garantir que os dados brutos fossem adquiridos, padronizados e disponibilizados de forma estruturada para as etapas subsequentes de análise espectral.

Abaixo, o status de cada tarefa atribuída no `README.md`:

- [x] **Aquisição e Estrutura:** Download seletivo e organização de pastas (`data/raw`).
- [x] **Leitura e Extração:** Implementação de *parser* inteligente (`load_data.m`).
- [x] **Pré-processamento:** Implementação de limpeza e normalização (`clean_signal.m`).
- [x] **Pipeline ETL:** Automação do processamento e salvamento (`run_etl.m`).
- [x] **Orquestração:** Criação do script mestre (`mainP1.m`).
- [x] **Validação Visual:** Geração de gráficos de controle (`plot_time_comparison.m`).

---

## 2. Decisões de Projeto e Dataset

Para garantir a robustez da análise e atender aos requisitos de "sensibilidade a parâmetros" do edital, foram tomadas as seguintes decisões estratégicas:

### 2.1. Seleção dos Arquivos (Carga 0 HP)
Todos os arquivos selecionados operam com **Carga do Motor = 0 HP** (aprox. 1797 RPM).
* **Justificativa:** A ausência de carga minimiza o escorregamento (*slip*) do motor, mantendo a frequência de rotação mais estável entre os diferentes testes. Isso evita o "borrão" espectral e facilita a validação das frequências características de falha (BPFO/BPFI).

### 2.2. Estratégia de Severidade (0.007" vs 0.021")
Foram selecionados dois níveis de severidade de falha para enriquecer a discussão dos resultados:
1.  **Leve (0.007"):** Simula uma falha incipiente. Desafia a sensibilidade do algoritmo.
2.  **Severa (0.021"):** Simula uma falha avançada. Serve como "controle positivo" para validação óbvia.

**Arquivos Mapeados (`src/config.m`):**
* **Saudável:** `97.mat` (Baseline)
* **Falhas Leves:** `105.mat` (Inner), `118.mat` (Ball), `130.mat` (Outer)
* **Falhas Graves:** `209.mat` (Inner), `222.mat` (Ball), `234.mat` (Outer)

---

## 3. Implementação Técnica

Abaixo descrevo a função de cada script desenvolvido na pasta `src/preprocessing/`.

### 3.1. Orquestrador (`src/preprocessing/mainP1.m`)
Script principal que gerencia todo o fluxo da Parte 1.
* **Função:** Verifica a integridade dos arquivos na pasta `raw`, executa o pipeline de ETL e gera os gráficos de validação. É o único arquivo que precisa ser executado para reproduzir o trabalho desta etapa.

### 3.2. Leitura Inteligente (`src/preprocessing/load_data.m`)
* **O Desafio:** Os arquivos `.mat` originais do CWRU possuem nomes de variáveis inconsistentes (ex: `X097_DE_time` vs `X105_DE_time`).
* **A Solução:** Implementei um algoritmo que carrega o arquivo e varre dinamicamente suas variáveis internas buscando aquela que contém o sufixo `_DE_time`, abstraindo essa complexidade.

### 3.3. Pré-processamento Matemático (`src/preprocessing/clean_signal.m`)
Função aplicada a todos os sinais antes de serem salvos.

**A. Remoção de Nível DC (Viés)**
```matlab
y = x - mean(x);
````

  * **Justificativa:** Acelerômetros piezoelétricos frequentemente apresentam um offset de tensão DC. Se não removido, gera um pico espúrio em 0 Hz na FFT.

**B. Normalização Z-Score**

```matlab
y_norm = y / std(y);
```

  * **Justificativa:** Normaliza o sinal para unidades de "Desvio Padrão". Isso permite comparar a morfologia da onda entre falhas leves e graves, independentemente do ganho absoluto do sensor naquele dia.

### 3.4. Pipeline de Persistência (`src/preprocessing/run_etl.m`)

Automatiza a transformação. Itera sobre a lista de arquivos do `config.m`, aplica a limpeza e salva os resultados (ex: `inner_light.mat`) na pasta `data/processed/`.

### 3.5. Validação Visual (`src/preprocessing/plot_time_comparison.m`)

Gera a figura `time_domain_comparison.png` em `results/figures`.

  * **Análise:** O gráfico comprova que, no domínio do tempo, o sinal saudável é estocástico (ruído), enquanto o sinal com falha apresenta impulsos periódicos claros. Esta figura justifica a necessidade da análise espectral (FFT) que será feita.

-----

## 4\. Infraestrutura Global (`src/config.m`)

Para evitar erros de "Arquivo não encontrado" ao trocar de computador, implementei o uso de **caminhos absolutos dinâmicos**.

  * O script detecta a raiz do projeto usando `fileparts(mfilename('fullpath'))`.
  * **Resultado:** O código é portável e roda em qualquer máquina sem configuração manual de diretórios.

-----

## 5\. Próximos Passos

A infraestrutura está pronta e testada.

**Instruções para o próximo:**

1.  Certifique-se de que a pasta `data/processed/` contém os arquivos `.mat` gerados (caso contrário, rode `mainP1.m`).
2.  Para carregar um sinal, utilize o comando padrão do MATLAB:
    ```matlab
    load('data/processed/inner_light.mat'); % Carrega o sinal processado
    % A variável disponível no workspace será 'clean_sig'
    ```
3.  Não é necessário utilizar `load_data` ou `clean_signal` novamente.

**Tarefas Técnicas Sugeridas para o Membro 2 (Spectral):**
O objetivo agora é transformar esses sinais do domínio do tempo para a frequência.

  * **Implementar FFT:** Aplicar `fft()` no vetor `clean_sig` para visualização preliminar. Lembre-se de criar o vetor de frequência correto ($f$) que vai de $0$ até $Fs/2$.
  * **Implementar Método de Welch:** Utilizar a função `pwelch()` para obter uma estimativa de densidade espectral (PSD) mais limpa.
  * **Comparativo de Janelas:** Testar e comparar o impacto de janelas como *Hann* e *Hamming* na redução do vazamento espectral (*spectral leakage*).


-----

```
```