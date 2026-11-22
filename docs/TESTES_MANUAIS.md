# Roteiro de validação — Física em Ação (GameMaker)

## Preparação
- [ ] Atualizar o projeto local no GitHub Desktop (Fetch/Pull).
- [ ] Abrir `projeto-software-educativo.yyp` no GameMaker.
- [ ] Confirmar que `obj_fisica` aparece no Asset Browser e na `Room1`.
- [ ] Compilar com F5 sem erros de GML nem de recursos.

## Experiência de aprendizagem
- [ ] Menu inicial abre; iniciar módulo 1.
- [ ] Ajustar ângulo com setas, roda do mouse e clique na barra.
- [ ] Clicar TESTAR: trajetória aparece, a esfera cai e a diferença em metros é exibida.
- [ ] Resposta errada: sequência zera, permite até 3 tentativas por problema.
- [ ] Resposta correta: conta acerto, registra pontos e carrega próximo problema.
- [ ] Três acertos consecutivos: desbloqueia lançamento horizontal.
- [ ] Três novos acertos: desbloqueia frenagem.
- [ ] Após completar frenagem, tela de conclusão aparece.
- [ ] Fechar e reabrir: módulo desbloqueado e pontos permanecem.
- [ ] Pressionar Esc: menu aparece, e Continuar retorna ao estado anterior.

## Ajuda ao aluno
- [ ] Aba FÓRMULA contém equação, significado das variáveis e dica.
- [ ] Tecla H exibe/oculta dica.
- [ ] TAB alterna para CADERNO.
- [ ] Mouse desenha sobre o papel; LIMPAR apaga.
- [ ] Calculadora aceita dois números com ponto decimal e quatro operações.
- [ ] Divisão por zero gera aviso sem travar o jogo.

## Cenários de referência
- Lançamento oblíquo, primeiro problema: **v0 = 25 m/s** e **ângulo = 22°** produz alcance aproximado de **44,30 m**.
- Horizontal, primeiro problema: **h = 12 m** e **vx = 12 m/s** produzem alcance aproximado de **18,78 m**.
- Frenagem, primeiro problema: **v0 = 18 m/s** e **a = 4 m/s²** produzem parada a **40,5 m**.

O avaliador aceita desvio de até **2 m**, incluindo os extremos. Essa regra verifica o resultado físico, não exige que a entrada seja idêntica à solução numérica.

## Limitações conhecidas do MVP
- Interface desenhada para área virtual de 1366x768; versões móveis e telas muito estreitas ainda não estão otimizadas.
- Não existem sons, sprites externos, relatórios por estudante ou sincronização de progresso pela internet.
- A escrita no caderno é feita com traços de mouse, sem reconhecimento matemático de escrita manual.
- A calculadora possui duas entradas e operações básicas; não faz seno inverso ou raízes diretamente.
- A compilação real e a experiência visual dependem da execução no GameMaker local.

Se algum passo falhar, encaminhar a mensagem exata do compilador e, quando possível, uma captura de tela do estado apresentado.
