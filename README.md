# Física em Ação — MVP educativo (GameMaker)

Protótipo de aprendizagem de física por experimentação e **domínio progressivo**.

## Como abrir

1. No **GitHub Desktop**, faça **Fetch origin → Pull origin**.
2. Abra `projeto-software-educativo/projeto-software-educativo.yyp` no **GameMaker 2024.14** (ou versão compatível).
3. Execute com **F5**. A sala inicial `Room1` já contém `obj_fisica`.

> **Importante:** esta versão foi implementada e revisada por análise estática dos arquivos; a execução dentro do GameMaker precisa ser testada localmente. Não há binário incluído.

## Conteúdo jogável

| Módulo | O aluno descobre | Equações | Cenário |
| --- | --- | --- | --- |
| 1. Lançamento oblíquo | Ângulo (5° a 45°) | R = v0² sen(2θ) / g | Canhão e alvo |
| 2. Lançamento horizontal | Velocidade horizontal | t = √(2h/g); R = vx · t | Penhasco e esfera |
| 3. Frenagem (MRUV) | Módulo da desaceleração | d = v0² / (2a) | Carro e ponto de parada |

Gravidade **g = 9,8 m/s²**; movimento sem resistência do ar; terreno plano na decolagem/pouso oblíquo; frenagem com desaceleração constante. No lançamento oblíquo, limitamos o ângulo a 45° para trabalhar a solução de baixo ângulo sem ambiguidade com a segunda trajetória possível.

Cada módulo possui **seis exercícios-base**, percorridos de maneira determinística. Em cada exercício, o aluno tem até **três tentativas**. A simulação compara a **distância efetiva** com o alvo: erro de até **2 metros** é aceito. Cada acerto consecutivo aumenta uma sequência; errar zera a sequência. Com **três acertos seguidos em exercícios diferentes**, o próximo módulo é desbloqueado.

O desbloqueio e os pontos ficam armazenados no arquivo local `fisica_em_acao.ini` usando o sistema de armazenamento do GameMaker. Não existe coleta de dados pessoais, conexão de rede ou conta de aluno neste MVP.

## Controles

- **← / →**, **↑ / ↓** ou **roda do mouse**: ajustar resposta.
- **Shift + seta**: alterar em passos de cinco unidades (ou cinco vezes o passo do módulo).
- **Clique na barra inferior**: ajustar diretamente.
- **Espaço / Enter**: testar a resposta; Enter avança após o resultado.
- **TAB**: alternar entre `FÓRMULA` e `CADERNO`.
- **H**: mostrar/ocultar dica na aba de fórmula.
- **Caderno**: arraste o mouse sobre a folha para rabiscar; **LIMPAR** apaga os rabiscos.
- **Calculadora**: clique em A ou B, digite números (separe decimais com ponto) e escolha `+`, `-`, `x` ou `/`. A linha científica oferece `sen` (graus), `asin` (resultado em graus), `raiz` e `x2` (quadrado); essas funções usam apenas o valor A.
- **Esc / MENU**: retornar ao menu sem perder a atividade atual.

## Organização dos arquivos

```text
projeto-software-educativo/
  projeto-software-educativo.yyp
  rooms/Room1/Room1.yy
  objects/obj_fisica/
    obj_fisica.yy     # declaração do objeto
    Create_0.gml      # problemas, física, pontos, persistência
    Step_0.gml        # entradas, animação e calculadora
    Draw_64.gml       # simulação e interface desenhada na GUI
```

Os cenários e equações foram definidos como dados em `iniciar_questao()`, dentro de `Create_0.gml`, para facilitar a expansão futura. A proposta é testar presencialmente com alunos e, em uma próxima versão, adicionar explicações passo a passo, acessibilidade, relatórios de aprendizagem e exercícios gerados com mais variação.

## Verificação

Consulte [o roteiro de testes manuais](docs/TESTES_MANUAIS.md) e execute-o no GameMaker após receber a atualização.
