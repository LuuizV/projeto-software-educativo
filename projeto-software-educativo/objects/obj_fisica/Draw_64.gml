/// @description Interface, simulacao visual e paineis didaticos
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);

var _texto = function(_x, _y, _s, _cor, _tam) {
    draw_set_color(_cor);
    draw_text_transformed(_x, _y, string(_s), _tam, _tam, 0);
};
var _caixa = function(_x1, _y1, _x2, _y2, _cor) {
    draw_set_color(_cor);
    draw_roundrect(_x1, _y1, _x2, _y2, false);
};
// Evite chamar helpers locais de dentro de outra funcao anonima:
// o escopo de var no GML nao e capturado por esse metodo.
var _botao = function(_x1, _y1, _x2, _y2, _titulo, _cor) {
    draw_set_color(_cor);
    draw_roundrect(_x1, _y1, _x2, _y2, false);
    draw_set_color(cor_fundo);
    draw_text_transformed(_x1 + 18, _y1 + 13, string(_titulo), 1.45, 1.45, 0);
};

draw_rectangle_color(0, 0, gui_w, gui_h,
    cor_fundo, cor_fundo, make_color_rgb(20, 33, 57), make_color_rgb(20, 33, 57), false);

if (estado == "menu") {
    _caixa(255, 95, 1111, 700, cor_painel);
    _texto(445, 135, "FISICA EM ACAO", cor_amarelo, 3.1);
    _texto(402, 208, "APRENDA. EXPERIMENTE. DOMINE.", cor_texto, 1.5);
    _texto(335, 265, "Resolva desafios de fisica ajustando os valores da simulacao.", cor_suave, 1.25);
    _texto(334, 302, "Cada tres acertos seguidos desbloqueiam um novo conteudo.", cor_suave, 1.25);
    _texto(334, 339, "Formula, dicas, rascunho e calculadora ao seu alcance.", cor_suave, 1.25);

    _botao(460, 384, 906, 456, (iniciado ? "CONTINUAR PARTIDA" : "COMECAR A APRENDER"), cor_amarelo);

    _texto(507, 480, "MODULO INICIAL (DESBLOQUEADOS)", cor_suave, 1.2);
    _caixa(468, 503, 535, 557, cor_painel_claro);
    _caixa(830, 503, 897, 557, cor_painel_claro);
    _texto(490, 513, "<", cor_texto, 2);
    _texto(853, 513, ">", cor_texto, 2);
    _texto(550, 519, nome_modulo(modulo_menu), cor_amarelo, 1.35);

    _botao(470, 595, 895, 650, "REINICIAR MODULO ESCOLHIDO", cor_azul);
    _texto(444, 671, "Seu progresso fica salvo neste computador.", cor_suave, 1.05);
    exit;
}

if (estado == "modulo_concluido" || estado == "jogo_concluido") {
    _caixa(252, 106, 1114, 681, cor_painel);
    _texto(406, 150, "CONTEUDO DOMINADO!", cor_verde, 2.8);
    _texto(365, 245, "Voce resolveu 3 problemas consecutivos sem errar.", cor_texto, 1.5);
    _texto(400, 301, "Seu entendimento foi demonstrado na pratica.", cor_suave, 1.3);
    _texto(493, 362, "Pontuacao: " + string(pontos), cor_amarelo, 1.75);
    if (estado == "modulo_concluido") {
        _texto(403, 432, "Proximo: " + nome_modulo(modulo + 1), cor_azul, 1.5);
        _botao(490, 525, 876, 601, "INICIAR PROXIMO MODULO", cor_verde);
    } else {
        _texto(405, 431, "Todos os modulos iniciais foram concluidos!", cor_azul, 1.4);
        _botao(490, 525, 876, 601, "VOLTAR AO MENU", cor_verde);
    }
    exit;
}

_caixa(14, 8, 1352, 134, cor_painel);
_caixa(22, 14, 142, 51, cor_painel_claro);
_texto(40, 23, "< MENU", cor_texto, 1.25);
_texto(166, 19, "MODULO " + string(modulo + 1) + "/3 - " + nome_modulo(modulo), cor_amarelo, 1.75);
_texto(1018, 23, "Pontos: " + string(pontos), cor_texto, 1.3);
_texto(1175, 23, "Serie: " + string(sequencia) + "/3", cor_verde, 1.3);
_texto(30, 68, "Problema " + string(questao + 1) + "  |  Tentativa " + string(min(tentativas + 1, 3)) + "/3", cor_azul, 1.3);

if (modulo == 0) {
    _texto(30, 101,
        "Um canhao dispara a " + string(cenario.velocidade) + " m/s. Qual angulo atinge o alvo a "
        + formatar_numero(cenario.distancia, 1) + " m?   (g = 9,8 m/s2)", cor_texto, 1.27);
} else if (modulo == 1) {
    _texto(30, 101,
        "Uma esfera cai de " + string(cenario.altura) + " m de altura. Qual velocidade horizontal a leva ate "
        + formatar_numero(cenario.distancia, 1) + " m?   (g = 9,8 m/s2)", cor_texto, 1.24);
} else {
    _texto(30, 101,
        "Um veiculo a " + string(cenario.velocidade) + " m/s deve parar em "
        + formatar_numero(cenario.distancia, 1) + " m. Qual desaceleracao constante usar?", cor_texto, 1.26);
}

// ===== SIMULACAO (area 20..1009 x 150..620) =====
draw_rectangle_color(20, 148, 1009, 618,
    make_color_rgb(27, 47, 81), make_color_rgb(27, 47, 81),
    make_color_rgb(69, 123, 184), make_color_rgb(69, 123, 184), false);
draw_set_color(make_color_rgb(80, 165, 104));
draw_rectangle(20, 581, 1009, 587, false);
draw_set_color(make_color_rgb(77, 64, 56));
draw_rectangle(20, 587, 1009, 618, false);

var _escala = min(9, 810 / max(60, cenario.distancia * 1.3));
var _ox = 116;
var _base_y = 581;
var _alvo_x = _ox + cenario.distancia * _escala;

// Metros ao longo do solo
for (var _m = 0; _m <= 170; _m += 10) {
    var _tick_x = _ox + _m * _escala;
    if (_tick_x > 989) break;
    draw_set_color(cor_suave);
    draw_line(_tick_x, 587, _tick_x, 596);
    _texto(_tick_x - 6, 602, string(_m) + "m", cor_texto, 0.86);
}

// Zona de acerto com tolerancia de 2 metros
draw_set_alpha(0.24);
draw_set_color(cor_verde);
draw_rectangle(_alvo_x - tolerancia * _escala, 564, _alvo_x + tolerancia * _escala, 581, false);
draw_set_alpha(1);
draw_set_color(cor_amarelo);
draw_rectangle(_alvo_x - 18, 575, _alvo_x + 18, 581, false);
draw_line_width(_alvo_x, 522, _alvo_x, 574, 3);
draw_triangle(_alvo_x, 523, _alvo_x + 32, 535, _alvo_x, 545, false);
_texto(_alvo_x - 27, 499, formatar_numero(cenario.distancia, 1) + " m", cor_texto, 1.1);

var _orig_y = _base_y;
if (modulo == 1) {
    _orig_y = _base_y - cenario.altura * _escala;
    draw_set_color(make_color_rgb(107, 111, 121));
    draw_rectangle(40, _orig_y, 116, 580, false);
    draw_set_color(cor_suave);
    draw_rectangle(36, _orig_y - 7, 123, _orig_y + 2, false);
    _texto(45, _orig_y - 31, string(cenario.altura) + " m", cor_texto, 1.2);
} else if (modulo == 0) {
    draw_set_color(make_color_rgb(94, 104, 126));
    draw_circle(_ox, 573, 18, false);
    draw_line_width(_ox, 570, _ox + 43 * dcos(resposta), 570 - 43 * dsin(resposta), 12);
}

// Desenho do caminho percorrido usa as mesmas equacoes do avaliador.
if (modulo != 2 && (estado == "simulacao" || estado == "resultado")) {
    var _t_final_desenho = min(tempo_tiro, tempo_final);
    var _passo_t = max(0.035, tempo_final / 70);
    draw_set_color(cor_amarelo);
    for (var _t = 0; _t <= _t_final_desenho; _t += _passo_t) {
        var _px_m = (modulo == 0) ? cenario.velocidade * dcos(resposta) * _t : resposta * _t;
        var _py_m = (modulo == 0)
            ? (cenario.velocidade * dsin(resposta) * _t - gravidade * sqr(_t) * 0.5)
            : (-gravidade * sqr(_t) * 0.5);
        var _px = _ox + _px_m * _escala;
        var _py = _orig_y - _py_m * _escala;
        if (_px <= 999 && _py >= 158 && _py <= 580) draw_circle(_px, _py, 2, false);
    }
}

if (modulo != 2) {
    var _tempo_atual = (estado == "simulacao" || estado == "resultado") ? tempo_tiro : 0;
    var _dx = (modulo == 0) ? cenario.velocidade * dcos(resposta) * _tempo_atual : resposta * _tempo_atual;
    var _dy = (modulo == 0)
        ? (cenario.velocidade * dsin(resposta) * _tempo_atual - gravidade * sqr(_tempo_atual) * 0.5)
        : (-gravidade * sqr(_tempo_atual) * 0.5);
    draw_set_color(cor_amarelo);
    draw_circle(clamp(_ox + _dx * _escala, 26, 1001), _orig_y - _dy * _escala, 8, false);
} else {
    var _car_x = _ox;
    if (estado == "simulacao" || estado == "resultado") {
        _car_x += (cenario.velocidade * tempo_tiro - 0.5 * resposta * sqr(tempo_tiro)) * _escala;
    }
    _car_x = clamp(_car_x, 38, 982);
    draw_set_color(cor_azul);
    draw_roundrect(_car_x - 25, 548, _car_x + 37, 573, false);
    draw_set_color(cor_fundo);
    draw_circle(_car_x - 12, 573, 7, false);
    draw_circle(_car_x + 24, 573, 7, false);
}

if (estado == "resultado") {
    var _impacto_x = clamp(_ox + alcance_real * _escala, 30, 997);
    draw_set_color(resultado_acerto ? cor_verde : cor_vermelho);
    draw_line_width(_impacto_x, 547, _impacto_x, 581, 3);
    _caixa(220, 176, 797, 265, cor_painel);
    _texto(245, 189, resultado_acerto ? "ACERTO! Muito bem!" : "AINDA NAO! Tente ajustar.", resultado_acerto ? cor_verde : cor_vermelho, 1.65);
    _texto(245, 228, "Distancia obtida: " + formatar_numero(alcance_real, 1) + " m  |  Diferenca: " + formatar_numero(erro_metros, 1) + " m",
        cor_texto, 1.18);
} else if (estado == "simulacao") {
    _caixa(335, 179, 693, 227, cor_painel);
    _texto(350, 189, "SIMULANDO... " + formatar_numero(tempo_tiro, 1) + " s", cor_amarelo, 1.5);
}

// ===== CONTROLES INFERIORES =====
_caixa(20, 630, 1009, 737, cor_painel);
_texto(39, 646, nome_variavel(), cor_amarelo, 1.6);
_texto(39, 687, formatar_numero(resposta, 1) + " " + unidade_variavel(), cor_texto, 1.5);
draw_set_color(cor_painel_claro);
draw_roundrect(299, 691, 748, 704, false);
var _proporcao = (resposta - resposta_min) / (resposta_max - resposta_min);
draw_set_color(cor_amarelo);
draw_roundrect(299, 691, 299 + 449 * _proporcao, 704, false);
draw_circle(299 + 449 * _proporcao, 697, 13, false);
_texto(299, 714, formatar_numero(resposta_min, 1), cor_suave, 0.94);
_texto(725, 714, formatar_numero(resposta_max, 1), cor_suave, 0.94);

if (estado == "resultado") {
    _botao(810, 669, 1001, 730,
        (resultado_acerto ? "PROXIMO" : ((tentativas < 3) ? "TENTAR NOVO" : "OUTRO DESAFIO")), cor_verde);
} else if (estado == "jogo") {
    _botao(810, 669, 1001, 730, "TESTAR", cor_amarelo);
} else {
    _caixa(810, 669, 1001, 730, cor_painel_claro);
    _texto(835, 687, "EM MOVIMENTO", cor_suave, 1.2);
}

// ===== PAINEL DE ESTUDOS (1040..1340) =====
_caixa(1025, 148, 1352, 738, cor_painel);
_caixa(1045, 155, 1181, 199, aba == 0 ? cor_amarelo : cor_painel_claro);
_caixa(1186, 155, 1335, 199, aba == 1 ? cor_amarelo : cor_painel_claro);
_texto(1060, 165, "FORMULA", aba == 0 ? cor_fundo : cor_texto, 1.27);
_texto(1200, 165, "CADERNO", aba == 1 ? cor_fundo : cor_texto, 1.27);

if (aba == 0) {
    _texto(1052, 217, "Aprenda antes de testar", cor_amarelo, 1.35);
    if (modulo == 0) {
        _texto(1050, 271, "LANCAMENTO OBLIQUO", cor_texto, 1.25);
        _texto(1050, 311, "R = v0^2 * sen(2a) / g", cor_verde, 1.35);
        _texto(1050, 358, "R: alcance horizontal", cor_suave, 1.05);
        _texto(1050, 384, "v0: velocidade inicial", cor_suave, 1.05);
        _texto(1050, 410, "a: angulo com o solo", cor_suave, 1.05);
        _texto(1050, 436, "g: gravidade (9,8)", cor_suave, 1.05);
        _texto(1050, 475, "Isole o angulo:", cor_texto, 1.12);
        _texto(1050, 505, "a = arcsen(R*g/v0^2) / 2", cor_azul, 1.07);
        mensagem_dica = "Calcule R*g/v0^2 e use arcsen.";
    } else if (modulo == 1) {
        _texto(1050, 271, "LANCAMENTO HORIZONTAL", cor_texto, 1.18);
        _texto(1050, 316, "t = raiz(2*h / g)", cor_verde, 1.32);
        _texto(1050, 354, "R = vx * t", cor_verde, 1.32);
        _texto(1050, 393, "h: altura de queda", cor_suave, 1.05);
        _texto(1050, 421, "t: tempo de queda", cor_suave, 1.05);
        _texto(1050, 449, "vx: velocidade horizontal", cor_suave, 1.05);
        _texto(1050, 494, "Isole vx = R / t", cor_azul, 1.2);
        mensagem_dica = "Primeiro encontre o tempo de queda.";
    } else {
        _texto(1050, 271, "FRENAGEM - MRUV", cor_texto, 1.25);
        _texto(1050, 316, "d = v0^2 / (2*a)", cor_verde, 1.35);
        _texto(1050, 358, "d: distancia de frenagem", cor_suave, 1.05);
        _texto(1050, 391, "v0: velocidade inicial", cor_suave, 1.05);
        _texto(1050, 423, "a: modulo da desaceleracao", cor_suave, 0.95);
        _texto(1050, 467, "Isole a = v0^2 / (2*d)", cor_azul, 1.18);
        mensagem_dica = "A desaceleracao e positiva aqui.";
    }
    // Exemplo de substituicao usando os dados da questao atual.
    if (modulo == 0) {
        _texto(1050, 547, "Use R=" + formatar_numero(cenario.distancia, 1) + " e v0=" + string(cenario.velocidade), cor_azul, 1.05);
    } else if (modulo == 1) {
        _texto(1050, 547, "Use h=" + string(cenario.altura) + " e R=" + formatar_numero(cenario.distancia, 1), cor_azul, 1.05);
    } else {
        _texto(1050, 547, "Use v0=" + string(cenario.velocidade) + " e d=" + formatar_numero(cenario.distancia, 1), cor_azul, 1.05);
    }
    _texto(1050, 584, usou_dica ? mensagem_dica : "Dica: isole a incognita.", cor_suave, 1.0);
    _texto(1050, 614, "Use o caderno para calcular.", cor_suave, 1.0);
    _caixa(1050, 662, 1328, 717, cor_azul);
    _texto(1071, 679, usou_dica ? "OCULTAR DICA" : "MOSTRAR DICA (H)", cor_fundo, 1.32);
} else {
    _texto(1050, 215, "Rabisque com o mouse", cor_texto, 1.16);
    _caixa(1205, 216, 1327, 257, cor_painel_claro);
    _texto(1219, 225, "LIMPAR", cor_texto, 1.1);
    draw_set_color(make_color_rgb(244, 246, 239));
    draw_rectangle(1050, 280, 1330, 492, false);
    draw_set_color(make_color_rgb(223, 227, 224));
    for (var _y = 305; _y < 491; _y += 25) draw_line(1050, _y, 1330, _y);
    draw_set_color(make_color_rgb(46, 58, 77));
    for (var _j = 0; _j < array_length(anotacoes); _j++) {
        var _seg = anotacoes[_j];
        draw_line_width(_seg.x1, _seg.y1, _seg.x2, _seg.y2, 2);
    }
    _texto(1050, 505, "Calculadora: clique e digite", cor_texto, 1.07);
    _caixa(1058, 542, 1175, 590, calc_foco == 0 ? cor_azul : cor_painel_claro);
    _caixa(1190, 542, 1315, 590, calc_foco == 1 ? cor_azul : cor_painel_claro);
    _texto(1072, 556, calc_a == "" ? "Numero A" : calc_a, cor_texto, 1.27);
    _texto(1200, 556, calc_b == "" ? "Numero B" : calc_b, cor_texto, 1.27);
    var _op = ["+", "-", "x", "/"];
    for (var _k = 0; _k < 4; _k++) {
        var _bx = 1056 + _k * 70;
        _caixa(_bx, 612, _bx + 62, 653, calc_operacao == _k ? cor_amarelo : cor_painel_claro);
        _texto(_bx + 24, 621, _op[_k], calc_operacao == _k ? cor_fundo : cor_texto, 1.35);
    }
    var _cientifica = ["sen", "asin", "raiz", "x2"];
    for (var _q = 0; _q < 4; _q++) {
        var _cx = 1056 + _q * 70;
        _caixa(_cx, 656, _cx + 62, 691, calc_operacao == _q + 4 ? cor_amarelo : cor_painel_claro);
        _texto(_cx + 10, 661, _cientifica[_q], calc_operacao == _q + 4 ? cor_fundo : cor_texto, 1.15);
    }
    _texto(1050, 701, "= " + resultado_calculadora(), cor_verde, 1.20);
}
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
