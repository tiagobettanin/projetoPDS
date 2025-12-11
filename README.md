# Projeto Final PDS — Detecção de Falhas em Rolamentos via Análise de Vibração

Repositório do projeto final da disciplina de **Processamento Digital de Sinais (2025/1)**, UTFPR/Apucarana.  
O objetivo é detectar e caracterizar **falhas em rolamentos** de motores de indução a partir de **sinais de vibração**, usando:

- **FFT** e **PSD via método de Welch**;
- **Espectro de envoltória** baseado na transformada de Hilbert;
- Frequências características de falha **BPFI, BPFO, BSF e FTF** do rolamento **6205‑2RS JEM**.

Os dados são do **Case Western Reserve University Bearing Data Center**.

---

## 1. Estrutura do Repositório

```text
projetoPDS/
├── data/
│   ├── raw/           # Arquivos .mat originais do CWRU (Drive End, 12 kHz, 0 HP)
│   └── processed/     # Arquivos .mat limpos/normalizados (gerados pelo pipeline)
│
├── results/
│   └── figures/       # Figuras geradas para o artigo (time-domain, PSD, envelope, etc.)
│
├── docs/
│   ├── paper/         # Arquivos auxiliares do artigo (opcional)
│   └── presentation/  # Slides de apresentação (opcional)
│
└── src/
    ├── config.m               # Configuração global (caminhos absolutos, fs, mapeamento de arquivos)
    ├── main.m                 # Script principal que orquestra todo o pipeline
    │
    ├── preprocessing/
    │   ├── mainP1.m           # Parte 1: verificação, ETL e gráficos no tempo
    │   ├── run_etl.m          # Limpeza, recorte, normalização e salvamento em data/processed
    │   └── plot_time_comparison.m
    │
    ├── diagnostics/
    │   └── diagnostics_metrics.m
    │       # Usa o espectro de envoltória para gerar figuras e métricas por condição
    │
    ├── spectral/
    │   └── spectral_analysis.m
    │       # FFT, PSD por Welch e comparação de janelas

```

> Obs.: A função `config.m` descobre automaticamente a raiz do projeto a partir da pasta `src`, definindo os caminhos de `data/` e `results/`.

---

## 2. Requisitos de Software

- **MATLAB** (recomendado R2023b ou similar).
- **Signal Processing Toolbox** (MathWorks)  
  - Incluída na licença acadêmica da universidade.  
  - Usada para `pwelch`, janelas, etc.
- **Statistics and Machine Learning Toolbox** (MathWorks)  
  - Incluída na licença acadêmica.  
  - Usada para algumas métricas estatísticas.

---

## 3. Como Reproduzir os Resultados

### 3.1. Preparar os dados

1. Baixar os arquivos do **CWRU Bearing Data Center**:  
   <https://engineering.case.edu/bearingdatacenter>
2. Copiar para `data/raw/` os seguintes arquivos (nomes compatíveis com `src/config.m`):
   - `97.mat` — rolamento saudável (baseline);
   - `105.mat` — pista interna leve (0.007");
   - `118.mat` — esfera leve (0.007");
   - `130.mat` — pista externa leve (0.007");
   - `209.mat` — pista interna grave (0.021");
   - `222.mat` — esfera grave (0.021");
   - `234.mat` — pista externa grave (0.021").

A frequência de amostragem usada é **12 kHz**, com motor sem carga a aproximadamente **1797 rpm**.

### 3.2. Executar o pipeline no MATLAB

1. Abrir o MATLAB e definir o diretório atual como a raiz do projeto `projetoPDS/`.
2. Garantir que o `Signal Processing Toolbox` e o `Statistics and Machine Learning Toolbox` estão instalados.
3. No prompt do MATLAB, executar:

   ```matlab
   % adiciona src e subpastas ao path e roda o pipeline completo
   main
   ```
OBS: Vai abrir muitos graficos.
O script `src/main.m` realiza:

1. **Parte 1 — Pré-processamento (`src/preprocessing/mainP1.m`)**
   - Verifica integridade dos arquivos em `data/raw/`.
   - Executa o ETL (`run_etl.m`): remoção de DC, normalização (Z‑score), recorte (tipicamente 1 s).
   - Salva arquivos limpos em `data/processed/` com nomes lógicos (`baseline.mat`, `inner_light.mat`, etc.).
   - Gera gráficos comparativos no tempo em `results/figures/` (e/ou `imagens/`).

2. **Parte 2 — Diagnóstico (`src/diagnostics/diagnostics_metrics.m`)**
   - Carrega cada condição (`baseline`, `inner_light`, `ball_light`, …).
   - Calcula frequências características (FTF, BPFI, BPFO, BSF) a partir da rotação.
   - Aplica análise de envoltória (Hilbert) e gera figuras com marcadores de falha.
   - Salva PNG em `results/figures/` e PDFs vetoriais em `results/figures_pdf/`.
   - Calcula métricas: RPM, RMS, fator de crista, curtose, energia em banda de envoltória.

3. **Parte 3 — Análise espectral (`src/spectral/spectral_analysis.m`)**
   - Calcula FFT unilateral dos sinais limpos.
   - Estima a **PSD via método de Welch** com diferentes janelas (Hamming vs. Retangular).
   - Gera figuras comparativas para cada condição de falha.

---

## 4. Relação com o Enunciado da Disciplina

Trechos principais do enunciado:

- **“FFT e Welch para PSD”**  
  Implementados em `src/spectral/spectral_analysis.m`, com discussão conceitual no relatório/artigo do projeto.

- **“Frequências características do rolamento”**  
  Calculadas e utilizadas no código (por exemplo em `diagnostics_metrics.m` e funções auxiliares), com interpretação física descrita no relatório/artigo.

- **“Resultados esperados: espectros comparativos saudável vs. falha”**  
  Gerados pelos scripts MATLAB (figuras em `results/figures/`) e discutidos em detalhe no relatório e na apresentação.

---

## 5. Referências Principais

- **Banco de dados**:  
  *Case Western Reserve University Bearing Data Center* — <https://engineering.case.edu/bearingdatacenter>
