# Skills - Antigravity CLI

As **Skills** são pacotes modulares de conhecimento, procedimentos e automações que estendem as capacidades do agente no Antigravity CLI. Elas funcionam como manuais práticos ("runbooks" ou "cheatsheets") para fluxos de trabalho específicos.

---

## 📁 Onde colocar as Skills

As skills podem ser adicionadas tanto a nível global (para todos os projetos) quanto a nível local (no próprio repositório/projeto):

1. **No Projeto (Workspace / Repositório):**
   * Caminho: `.agents/skills/<nome-da-skill>/`
   * Ideal para compartilhar com o time via Git.
2. **Global (Máquina Local):**
   * Caminho: `~/.gemini/antigravity-cli/skills/<nome-da-skill>/` ou `~/.gemini/config/skills/<nome-da-skill>/`
   * Aplica-se a todos os workspaces e projetos abertos na máquina.

---

## 📂 Estrutura de Diretórios de uma Skill

Cada skill deve ter seu próprio diretório contendo obrigatoriamente um arquivo `SKILL.md`:

```text
skills/<nome-da-skill>/
├── SKILL.md          # Obrigatório: Instruções principais com frontmatter YAML
├── scripts/          # Opcional: Scripts auxiliares executáveis
├── examples/         # Opcional: Exemplos de código e referências de implementação
├── resources/        # Opcional: Templates e assets adicionais
└── references/       # Opcional: Documentações detalhadas e manuais
```

---

## 📝 Estrutura do `SKILL.md`

O arquivo `SKILL.md` deve começar com um bloco de **Frontmatter YAML** contendo `name` e `description`:

```markdown
---
name: meu-workflow-especializado
description: >-
  Descreva quando o agente deve usar esta skill. Escreva sempre em 3ª pessoa.
  Exemplo: "Use esta skill quando o usuário solicitar execução de testes de integração ou deploy da aplicação."
---

# Meu Workflow Especializado

Instruções claras e passo a passo para o agente executar a tarefa.

## Passos

1. Execute o script de validação:
   `./scripts/validar.sh`
2. Execute o comando de build ou teste.
3. Verifique os logs e reporte o resultado.
```

### Campos do Frontmatter:
* **`name`** *(obrigatório)*: Identificador único em minúsculas e separado por hífen (ex: `deploy-staging`, `code-review-rules`).
* **`description`** *(obrigatório)*: Descrição clara do **que** a skill faz e **quando** deve ser ativada. O agente lê esta descrição para decidir dinamicamente se precisa carregar a skill.

---

## 💡 Boas Práticas

1. **Progressive Disclosure (Divulgação Progressiva):** Mantenha o `SKILL.md` enxuto. Coloque manuais longos na pasta `references/` e crie links para eles. O agente só lerá os arquivos de referência se for necessário.
2. **Scripts Auxiliares:** Automatize comandos complexos colocando scripts na pasta `scripts/` e fazendo referência a eles.
3. **Validação:** Sempre descreva como verificar se uma etapa foi concluída com sucesso.
