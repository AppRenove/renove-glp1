# Renove GLP-1

App mobile-first para acompanhamento de tratamento com GLP-1 (Tirzepatida / Semaglutida).  
Desenvolvido como single-page app em React + Babel standalone, sem build step.

---

## Como rodar localmente

**Windows — duplo clique em `Iniciar App.bat`**  
Requer Node.js instalado. Abre servidor em `http://localhost:3000` e abre o Chrome automaticamente.

**Qualquer OS — via npx:**
```bash
npx serve . --listen 3000
```

---

## Estrutura do projeto

```
Renove App/
├── index.html          # App completo (React + Babel standalone, ~3500 linhas)
├── config.js           # Chave OpenAI local — NÃO vai pro GitHub (.gitignore)
├── Iniciar App.bat     # Launcher Windows
│
├── api/
│   └── chat.js         # Vercel Serverless Function — proxy seguro para OpenAI
│
├── assets/
│   ├── ampola.mp4      # Vídeo real de ampola farmacêutica (onboarding)
│   └── renove_logo_v3.png
│
├── docs/
│   ├── Renove_GLP1_Projeto_Completo.docx
│   └── prompt_logo_renove_glp1.md
│
└── .github/
    └── workflows/      # CI/CD (Vercel deploy)
```

---

## Tecnologias

| Camada | Tecnologia |
|--------|-----------|
| UI | React 18 (Babel standalone — sem bundler) |
| Estilo | CSS inline + variáveis CSS custom |
| IA (Rê) | OpenAI GPT-4o-mini via proxy Vercel |
| Persistência | localStorage (sem banco de dados) |
| Deploy | Vercel (serverless functions) |

---

## Configuração da API

Crie o arquivo `config.js` na raiz com:

```js
window.__RENOVE_API_KEY__ = 'sk-proj-SUA_CHAVE_AQUI';
```

Em produção (Vercel), a chave fica na variável de ambiente `OPENAI_API_KEY`.

---

## Funcionalidades principais

- **Onboarding** — cadastro completo: medicamento, dose, ampola, peso, objetivos
- **Home** — dashboard com próxima aplicação, progresso e tarefas do dia
- **Planejador (Picadinha)** — calendário semanal, cálculo de dose/UI na seringa, histórico
- **Diário** — registro diário de sintomas, hidratação e humor
- **Peso** — gráfico de evolução, medidas corporais
- **Rê (chat)** — assistente GLP-1 com contexto personalizado do perfil

---

## Cálculo farmacológico

O cálculo de dose segue a lógica U-100 (ver `AGENTS.md` para detalhes):

```
concentração  = totalAmpola_mg / volumeAmpola_ml
volume_ml     = dose_mg / concentração
unidades_UI   = volume_ml × 100
```

Funções centralizadas em `index.html` (seção `CÁLCULO FARMACOLÓGICO`):
`normalizarNumero`, `calcularConcentracao`, `calcularVolumeNecessario`,
`mlParaUnidades`, `validarLimiteSeringa`, `calcularDoseFarmaco`
