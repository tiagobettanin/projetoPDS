# Projeto Final PDS: Detecção de Falhas em Rolamentos via Análise de Vibração

Este repositório contém o código-fonte em MATLAB, dados e a documentação do Projeto Final da disciplina de Processamento Digital de Sinais (2025/2).

## 🎯 Contextualização e Objetivo Teórico
Rolamentos são componentes críticos em máquinas rotativas e estão sujeitos a desgaste mecânico. Quando ocorrem defeitos nas pistas (interna/externa) ou nas esferas, o movimento rotacional gera impactos periódicos que excitam a estrutura do motor.

Embora esses impactos existam no domínio do tempo, eles frequentemente estão mascarados por ruído de fundo. A teoria de monitoramento de condição estabelece que cada tipo de falha gera uma **assinatura espectral** específica, conhecida como frequência característica de falha (BPFO, BPFI, BSF, FTF), que depende estritamente da geometria do rolamento e da velocidade de rotação.

**O objetivo deste projeto** é implementar um sistema robusto de PDS que:
1.  Supere as limitações da análise temporal simples.
2.  Utilize a **Densidade Espectral de Potência (PSD)** via Método de Welch para reduzir a variância do estimador espectral e evidenciar componentes periódicas ocultas no ruído.
3.  Identifique visual e numericamente a presença de falhas comparando a energia nessas bandas de frequência específicas.

## 📂 Sobre os Dados
Os dados provêm do **Case Western Reserve University (CWRU) Bearing Data Center**.
* **Fonte:** [CWRU Bearing Data Center](https://engineering.case.edu/bearingdatacenter)
* **Aquisição:** Acelerômetros acoplados à carcaça (Drive End).
* **Freq. Amostragem:** 12 kHz ou 48 kHz (fundamental observar o Teorema de Nyquist).
* **Classes:** Normal (Baseline), Falha na Pista Interna, Falha na Pista Externa, Falha na Esfera.

---

## 📋 Backlog e Divisão de Tarefas (MATLAB)

Abaixo, o roadmap de desenvolvimento.

### 👤 Membro 1: Engenharia de Dados & Pré-processamento
**Responsável por:** Ingestão dos arquivos `.mat`, limpeza e análise temporal.
**Arquivo Principal:** `src/data_handler.m`

- [ ] **Aquisição e Estrutura**
    - [ ] Baixar dataset CWRU (focar em arquivos de *Drive End*).
    - [ ] Organizar pastas: `data/raw/` e `data/processed/`.
- [ ] **Leitura e Extração**
    - [ ] Criar script para carregar arquivos `.mat` usando a função `load()`.
    - [ ] Identificar automaticamente o vetor de vibração (ex: variáveis `X097_DE_time`, etc).
- [ ] **Pré-processamento de Sinais**
    - [ ] Implementar remoção de nível DC: `y = x - mean(x)`.
    - [ ] Implementar normalização (Z-score) para comparar sinais com amplitudes diferentes.
- [ ] **Visualização Temporal**
    - [ ] Plotar `Amplitude x Tempo` (subplot) comparando: Sinal Saudável vs. Com Falha.

### 👤 Membro 2: DSP Core (Análise Espectral)
**Responsável por:** Implementação matemática das transformadas e janelamento.
**Arquivo Principal:** `src/spectral_analysis.m`

- [ ] **Implementação FFT**
    - [ ] Calcular FFT unilateral usando `fft()`.
    - [ ] Gerar o vetor de frequências correto: `f = (0:N-1)*(fs/N)`.
- [ ] **Implementação Método de Welch (PSD)**
    - [ ] Utilizar a função `pwelch()` do MATLAB.
    - [ ] Definir parâmetros ótimos: Janela (`hamming`, `hann`), `noverlap` (50%) e `nfft`.
    - [ ] Justificar a escolha da janela baseada no vazamento espectral (spectral leakage).
- [ ] **Comparativo de Janelas**
    - [ ] Gerar gráfico sobreposto comparando o PSD com janela Retangular vs. Hamming para demonstrar a redução dos lobos laterais.

### 👤 Membro 3: Diagnóstico, Métricas & Relatório
**Responsável por:** Mapeamento de falhas, validação e escrita do artigo IEEE.
**Arquivo Principal:** `src/diagnostics/diagnostics_metrics.m`

- [x] **Marcadores de Frequência de Falha**
    - [x] Calcular as frequências teóricas (BPFO, BPFI) para o rolamento do dataset (geralmente rolamento SKF 6205).
    - [x] Adicionar linhas verticais (`xline`) nos gráficos de PSD para indicar onde a falha deveria estar.
- [x] **Métricas Quantitativas**
    - [x] Calcular RMS (Root Mean Square) dos sinais filtrados.
    - [x] (Opcional) Implementar classificação simples baseada na energia da banda de falha.
- [ ] **Produção do Artigo (LaTeX)**
    - [ ] Redigir Metodologia: Explicar por que o Welch é superior à FFT pura para este caso.
    - [ ] Compilar Resultados: Inserir as figuras `.fig` ou `.png` geradas pelo MATLAB.
    - [ ] Formatação final no modelo IEEE.

---

## 💻 Requisitos de Sistema

Para executar este projeto, é necessário:

1.  **MATLAB** (Versão R2020a ou superior recomendada).
2.  **Signal Processing Toolbox** (Essencial para funções como `pwelch` e janelamento).

## 📦 Entregáveis

- [ ] **Código Fonte (.m)**
    - [ ] Scripts organizados e comentados.
    - [ ] Arquivo `main.m` que chama as funções dos membros e gera todos os resultados.
- [ ] **Artigo Científico (PDF)**
    - [ ] Modelo IEEE, 4-8 páginas.
    - [ ] Discussão sobre a estabilidade do espectro e influência das janelas.
- [ ] **Apresentação**
    - [ ] Slides para defesa oral.

---

## 📂 Estrutura de Diretórios

```
📦 projetoPDS/
│
├── 📄 Projeto_Final_PDS_2025_2.pdf   # PDF do edital/instruções
├── 📄 tiago.md
├── 📄 README.md                      # Documentação principal
│
├── 📁 data/                          # Base de dados
│   ├── 📁 processed/                 # (Vazio por enquanto) Cache de dados
│   └── 📁 raw/                       # Arquivos originais do CWRU (Carga 0 HP)
│       ├── 97.mat                    # Saudável (Baseline)
│       ├── 105.mat                   # Pista Interna (Leve - 0.007")
│       ├── 118.mat                   # Esfera (Leve - 0.007")
│       ├── 130.mat                   # Pista Externa (Leve - 0.007")
│       ├── 209.mat                   # Pista Interna (Grave - 0.021")
│       ├── 222.mat                   # Esfera (Grave - 0.021")
│       └── 234.mat                   # Pista Externa (Grave - 0.021")
│
├── 📁 docs/                          # Documentação Acadêmica
│   ├── 📁 paper/                     # Arquivos LaTeX do artigo
│   └── 📁 presentation/              # Slides para defesa
│
├── 📁 results/                       # Resultados Gerados
│   └── 📁 figures/                   # Figuras para o artigo
│       └── 🖼️ time_domain_comparison.png  # Gráfico gerado pelo Membro 1
│
└── 📁 src/                           # Código Fonte MATLAB
    ├── ⚙️ config.m                   # Configuração de caminhos absolutos
    ├── 🎮 main.m                     # Script principal (A fazer)
    │
    ├── 📁 diagnostics/               # [Membro 3] Análise e Resultados
    │   ├── fault_markers.m           # (A fazer)
    │   └── plot_results.m            # (A fazer)
    │
    ├── 📁 preprocessing/             # [Membro 1] Engenharia de Dados (CONCLUÍDO)
    │   ├── clean_signal.m            # Remoção de DC e Normalização Z-score
    │   ├── load_data.m               # Leitura inteligente dos .mat
    │   ├── mainP1.m                  # Funcao principal dessa parte
    │   ├── run_etl.m                 # Script de processamento em lote
    │   └── plot_time_comparison.m    # Gerador da figura de tempo
    │
    └── 📁 spectral/                  # [Membro 2] Processamento Espectral
        ├── calc_fft.m                # (A fazer)
        └── calc_welch.m              # (A fazer)
```
