# AGENTS.md — Guia para agentes de IA (Claude / Codex)

Este documento é o mapa completo do projeto para uso por agentes de IA.  
Leia antes de qualquer modificação no código.

---

## Arquitetura

**Single-file React app** — todo o código vive em `index.html`.  
Babel standalone compila JSX no browser — **não há build step, webpack, nem node_modules**.  
Adicionar dependências externas = adicionar `<script>` no `<head>`.

---

## Estrutura do `index.html`

O arquivo tem ~3500 linhas divididas em seções marcadas com comentários `/* ─── */`:

```
1.   <head>          CSS global, variáveis de cor, animações
2.   UTILS           parseLocalDate, hoje, diffDias
3.   CÁLCULO FARM.   normalizarNumero → calcularDoseFarmaco (fonte única)
4.   DADOS           LOCAIS[], MSGS_INICIAIS[], buildSistemaRe()
5.   ICON            Componente <Icon name="..." /> (Lucide via CDN)
6.   VIAL ANIMATION  VialAnimation — vídeo de ampola com anotação
7.   ReHeadIcon      SVG animado do rosto da Rê
8.   ReFAB           Botão flutuante global (apenas em App, não duplicar)
9.   CONFETTI        Animação de confete pós-aplicação
10.  SeringaSVG      Seringa estática SVG (seletor U-30/50/100)
11.  SyringeVisualizer  Barra horizontal (legado — não usar no Planejador)
12.  SeringaAnimada  Seringa vertical com animação de preenchimento ← USE ESTA
13.  ApplicacaoAnimada  Guia passo a passo (5 passos auto-cycling)
14.  HomeScreen      Dashboard principal
15.  PlanejadorScreen  Aba "Picadinha" — seletor de seringa + cálculo
16.  DiarioScreen    Registro diário de sintomas
17.  PesoScreen      Gráfico de peso + medidas corporais
18.  ReScreen        Chat com a IA Rê
19.  CalculadoraScreen  Calculadora de composição corporal
20.  NotificacoesScreen  Configuração de notificações
21.  PerfilScreen    Edição de perfil
22.  Step4Ampola     Componente isolado (evita perda de foco nos inputs)
23.  OnboardingScreen  Fluxo de cadastro (12 steps)
24.  App             Root — controla tab ativa, renderiza ReFAB global
```

---

## localStorage — chaves usadas

| Chave | Tipo | Conteúdo |
|-------|------|---------|
| `renove_perfil` | JSON object | Perfil completo do usuário |
| `renove_aplicacoes` | JSON array | Histórico de aplicações |
| `renove_diario` | JSON object | `{ "2025-01-01": { sintomas, hydra } }` |
| `renove_pesos` | JSON array | `[{ data, peso, dataISO }]` |
| `renove_medidas` | JSON array | `[{ data, cintura, quadril, braco, coxa }]` |
| `renove_chat_msgs` | JSON array | Últimas 60 msgs do chat com a Rê |
| `renove_chat_historico` | JSON array | Histórico de sessões anteriores |
| `renove_notif` | JSON object | Configurações de notificação |
| `renove_ultima_notif` | string ISO | Data da última notificação enviada |
| `renove_seringa_ui` | string | Tipo de seringa: "30", "50" ou "100" |

---

## Perfil do usuário — campos

```js
{
  nome: string,
  medicamento: string,          // 'Tirzepatida' | 'Semaglutida' | 'Outro'
  dose: string,                 // ex: '2,5mg', '5mg'
  dataInicio: string,           // 'YYYY-MM-DD'
  sexo: string,
  pesoInicio: number,
  pesoAtual: number,
  meta: number,
  objetivos: string[],
  totalAmpola: string,          // mg total na ampola, ex: '15'
  volumeMl: string,             // volume total em ml, ex: '2'
  concentracaoAmpola: string,   // calculada: '7.50mg/ml' | 'caneta' | 'nao-sei'
  status: string,               // 'iniciando' | 'em_tratamento'
}
```

---

## Cálculo farmacológico — REGRAS OBRIGATÓRIAS

> **Fonte única:** todas as telas usam as funções centralizadas.  
> Nunca calcule concentração ou UI inline fora dessas funções.

```js
// 1. Normalizar entrada (aceita vírgula ou ponto)
normalizarNumero(str) → number | NaN

// 2. Concentração
calcularConcentracao(totalAmpola_mg, volume_ml) → { ok, valor (mg/mL) }

// 3. Volume necessário
calcularVolumeNecessario(dose_mg, concentracao_mgMl) → { ok, valor (mL) }

// 4. Converter mL → UI (sempre lógica U-100)
mlParaUnidades(volumeMl) → number   // volume * 100

// 5. Validar capacidade da seringa
validarLimiteSeringa(unidades, tipoUI) → { ok, mensagem? }
// Limites: U-100 = 100UI/1mL | U-50 = 50UI/0.5mL | U-30 = 30UI/0.3mL

// 6. Pipeline completo
calcularDoseFarmaco(totalMg, volumeMl, doseMg, tipoSeringa) → {
  concentracao, volumeMl, unidades,           // raw (sem arredondar)
  concDisplay,  volDisplay,  uiDisplay,       // arredondados para exibição
  excedente, msgExcedente
}
```

**Arredondamento APENAS na exibição:**
- Concentração: `.toFixed(2)` → `7.50 mg/mL`
- Volume: `.toFixed(3)` → `0.333 mL`
- UI: `.toFixed(1)` → `33.3 UI`

---

## Datas — regras

Sempre usar `parseLocalDate(isoStr)` ao converter strings ISO para Date.  
**Nunca** `new Date('2025-01-01')` — causa bug de timezone (UTC vs GMT-3).

```js
// ✅ Correto
const d = parseLocalDate(perfil.dataInicio);

// ❌ Errado — pode retornar dia anterior em GMT-3
const d = new Date(perfil.dataInicio);
```

Para "hoje" use `const _hoje = hoje()` (retorna Date com horas zeradas).

---

## Componentes — regras de uso

### ReFAB (botão flutuante da Rê)
- Existe **apenas no `App` component** (linha ~3380)
- **Nunca adicionar** em telas individuais — causaria duplicata

### Step4Ampola
- Componente **separado** para evitar perda de foco nos inputs de ampola
- Regra do React: hooks não podem estar em condicionais
- Sempre que precisar de inputs com estado local em steps condicionais → componente separado

### SeringaAnimada vs SyringeVisualizer
- `SeringaAnimada` = seringa vertical com animação → USE no Planejador
- `SyringeVisualizer` = barra horizontal → legado, não usar em novas features

---

## Identidade visual — variáveis CSS

```css
--brown:        #2D1F14   /* marrom escuro principal */
--brown-mid:    #4A3222
--brown-light:  #6B4C35
--copper:       #C4885A   /* cobre — cor de destaque */
--copper-light: #D4A574
--copper-pale:  #F5EBE0   /* fundo suave */
--cream:        #F5EDE3
--cream-light:  #FAF7F4
--green:        #2E7D52
```

Fonte de display (títulos): **Fraunces** (serifada, carregada via Google Fonts)  
Fonte de corpo: **Inter** (sans-serif)

---

## Fluxo de trabalho Git

Commits seguem conventional commits:
```
feat: nova funcionalidade
fix: correção de bug
refactor: refatoração sem mudança de comportamento
style: ajuste visual sem lógica
docs: documentação
```

Branch principal: `main`  
Deploy automático via Vercel ao fazer push em `main`.

---

## O que NÃO fazer

- ❌ Não usar `Math.round()` para calcular UI — perde precisão
- ❌ Não duplicar ReFAB fora do `App` component  
- ❌ Não usar `new Date('YYYY-MM-DD')` diretamente
- ❌ Não calcular concentração inline — usar `calcularConcentracao()`
- ❌ Não criar arquivos CSS ou JS separados — tudo em `index.html`
- ❌ Não commitar `config.js` ou `stripe_backup_code.txt`
- ❌ Não usar `localStorage` diretamente no render — sempre no `useState` initializer ou `useEffect`
