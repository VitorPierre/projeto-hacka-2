# Progresso do Projeto — Hackathon SIF/UniRios 2026

## Decisões fixadas
- Stack principal: SQLite + Ruby on Rails + Tailwind CSS.
- Estilo de implementação: código simples, pragmático, sem complexidade desnecessária.
- Ferramenta de apoio: Antigravity com Gemini.
- Estratégia de continuidade: manter este arquivo markdown como memória operacional do projeto.
- Estratégia de prompts: instruções curtas, objetivas e econômicas em tokens.
- Regra de continuidade: antes de cada nova tarefa, ler este arquivo e continuar a mesma linha de raciocínio.

## Regras de trabalho
1. Priorizar funcionamento antes de refinamento.
2. Fazer o menor código possível para entregar valor.
3. Evitar abstrações prematuras, metaprogramação e arquitetura excessiva.
4. Manter nomes claros, arquivos curtos e responsabilidades simples.
5. Registrar aqui o que foi decidido, criado, alterado e o próximo passo.
6. Toda nova decisão relevante deve atualizar este arquivo.
7. Se houver dúvida, escolher a solução mais simples que atenda ao regulamento.

## Alinhamento com o regulamento
- O projeto precisa usar banco de dados.
- O projeto precisa usar framework.
- O projeto precisa ter README.md com descrição do projeto, tecnologias e versões, abordagens/metodologias, como executar e diagrama lógico do banco.
- Se faltar um requisito mínimo, a equipe pode ser desclassificada.
- A primeira etapa avalia: aderência ao tema, qualidade do código, funcionalidade e segurança.
- As 3 equipes com maior pontuação vão para a final.

## Linha de raciocínio adotada
- Preparar uma base Rails enxuta para adaptar rapidamente quando o tema sair.
- Favorecer CRUDs simples, autenticação básica e interface limpa.
- Estruturar o projeto para facilitar leitura por comissão avaliadora e análise automatizada.
- Tratar README e organização do repositório como parte do produto.

## Estrutura inicial sugerida
- Aplicação Rails com SQLite.
- Tailwind para interface rápida e limpa.
- README.md obrigatório e bem objetivo.
- Pasta ou seção com diagrama lógico do banco.
- Autenticação simples, se o tema exigir usuários.
- Modelos e controllers enxutos.

## Checklist contínuo
- [ ] Criar app base Rails
- [ ] Configurar Tailwind
- [ ] Definir estrutura mínima do domínio após o tema
- [ ] Modelar banco de dados
- [ ] Implementar fluxo principal
- [ ] Revisar segurança básica
- [ ] Escrever README final
- [ ] Gerar diagrama lógico
- [ ] Revisar execução local
- [ ] Enviar URL do GitHub

## Prompt base curto para continuidade
Use este progresso como memória do projeto. Leia o markdown de progresso antes de responder. Continue na mesma linha de raciocínio, com soluções simples, pragmáticas e curtas em tokens. Stack fixa: SQLite + Ruby on Rails + Tailwind CSS. Ferramenta: Antigravity com Gemini. Evite complexidade desnecessária, contexto longo e abstrações prematuras. Ao final, atualize o progresso com o que foi decidido e o próximo passo.

## Prompt curto para pedir implementação
Leia o markdown de progresso e continue de onde parou. Faça apenas o necessário para esta tarefa, com Rails simples, SQLite e Tailwind. Gere código enxuto, fácil de manter e alinhado ao hackathon.

## Estado atual
- Stack e forma de trabalho definidas.
- Ainda aguardando divulgação oficial do tema.
- Próximo foco: criar base reutilizável do projeto e templates de README/execução.
