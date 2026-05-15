# MagicTrip

Aplicativo iOS para planejar viagens internacionais. Guia o viajante do zero — desde documentação e datas até checklist de tarefas, calendário de itinerário e controle de orçamento.

## Funcionalidades

- **Onboarding guiado** — define destino, datas ou janela tentativa, composição do grupo, orçamento e situação documental
- **Checklist inteligente** — tarefas geradas por regras com base no perfil da viagem (país, documentos, crianças, mobilidade reduzida, etc.), com progresso e contagem de urgentes
- **Dicas de economia** — sugestões aplicáveis ao perfil com rastreamento de economia acumulada
- **Calendário de itinerário** — organiza atividades dia a dia com notas por dia
- **Ferramentas** — conversor de moeda com taxa em tempo real e calculadora de imposto de importação
- **Perfil editável** — atualiza dados da viagem a qualquer momento

## Tech Stack

- Swift + SwiftUI
- SwiftData (persistência local)
- iOS 17+

## Estrutura

```
MagicTrip/
├── DesignSystem/       # Componentes visuais (MTGroup, MTButton, FormDatePicker…)
├── Features/
│   ├── Onboarding/     # Fluxo de criação do perfil de viagem
│   ├── Checklist/      # Tela principal de tarefas e dicas
│   ├── Calendar/       # Itinerário dia a dia
│   ├── Tools/          # Conversor de moeda e calculadora de importação
│   └── Profile/        # Visualização e edição do perfil
├── Engine/             # Motor de regras do checklist
├── Models/             # SwiftData models
├── Services/           # Taxa de câmbio, notificações
└── Resources/          # Catálogos JSON (tarefas, países, sazonalidade)
```

## Como rodar

1. Clone o repositório
2. Abra `MagicTrip.xcodeproj` no Xcode 15+
3. Selecione o target e rode no simulador ou dispositivo iOS 17+

Não há dependências externas — sem CocoaPods, sem SPM.
