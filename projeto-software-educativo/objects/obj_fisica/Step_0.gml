/// @description Entradas, controles e simulacao a 60 FPS
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _clique = mouse_check_button_pressed(mb_left);

if (keyboard_check_pressed(vk_escape) && estado != "menu") {
    estado_pausado = estado;
    estado = "menu";
    calc_foco = -1;
    keyboard_string = "";
}

if (estado == "menu") {
    if (_clique) {
        if (clicou_em(_mx, _my, 460, 384, 906, 456)) {
            if (iniciado) {
                estado = estado_pausado;
            } else {
                iniciar_modulo(modulo_menu);
            }
        } else if (clicou_em(_mx, _my, 468, 503, 535, 557)) {
            modulo_menu = max(0, modulo_menu - 1);
        } else if (clicou_em(_mx, _my, 830, 503, 897, 557)) {
            modulo_menu = min(desbloqueado, modulo_menu + 1);
        } else if (clicou_em(_mx, _my, 470, 595, 895, 650)) {
            iniciado = false;
            iniciar_modulo(modulo_menu);
        }
    }
    exit;
}

// O canto superior esquerdo sempre volta ao menu.
if (_clique && clicou_em(_mx, _my, 22, 14, 142, 51)) {
    estado_pausado = estado;
    estado = "menu";
    calc_foco = -1;
    keyboard_string = "";
    exit;
}

if (estado == "modulo_concluido" || estado == "jogo_concluido") {
    if (_clique && clicou_em(_mx, _my, 490, 525, 876, 601)) {
        if (estado == "modulo_concluido") {
            iniciar_modulo(modulo + 1);
        } else {
            iniciado = false;
            estado = "menu";
            modulo_menu = desbloqueado;
        }
    }
    exit;
}

// A animacao preserva fisica em segundos, independentemente do FPS.
if (estado == "simulacao") {
    tempo_tiro += min(delta_time / 1000000, 0.05) * velocidade_sim;
    if (tempo_tiro >= tempo_final) {
        tempo_tiro = tempo_final;
        terminar_disparo();
    }
}

if (keyboard_check_pressed(vk_tab)) {
    aba = 1 - aba;
    calc_foco = -1;
    keyboard_string = "";
}

if (keyboard_check_pressed(ord("H")) && aba == 0) {
    usou_dica = !usou_dica;
}

if (_clique) {
    if (clicou_em(_mx, _my, 1045, 155, 1181, 199)) {
        aba = 0;
        calc_foco = -1;
        keyboard_string = "";
    } else if (clicou_em(_mx, _my, 1186, 155, 1335, 199)) {
        aba = 1;
        calc_foco = -1;
        keyboard_string = "";
    } else if (aba == 0 && clicou_em(_mx, _my, 1050, 662, 1328, 717)) {
        usou_dica = !usou_dica;
    } else if (aba == 1) {
        if (clicou_em(_mx, _my, 1205, 216, 1327, 257)) {
            anotacoes = [];
        } else if (clicou_em(_mx, _my, 1050, 280, 1330, 492)) {
            riscando = true;
            risco_x = _mx;
            risco_y = _my;
            calc_foco = -1;
            keyboard_string = "";
        } else if (clicou_em(_mx, _my, 1058, 542, 1175, 590)) {
            calc_foco = 0;
            keyboard_string = calc_a;
        } else if (clicou_em(_mx, _my, 1190, 542, 1315, 590)) {
            calc_foco = 1;
            keyboard_string = calc_b;
        } else if (clicou_em(_mx, _my, 1056, 612, 1118, 653)) {
            calc_operacao = 0;
        } else if (clicou_em(_mx, _my, 1126, 612, 1188, 653)) {
            calc_operacao = 1;
        } else if (clicou_em(_mx, _my, 1196, 612, 1258, 653)) {
            calc_operacao = 2;
        } else if (clicou_em(_mx, _my, 1266, 612, 1328, 653)) {
            calc_operacao = 3;
        } else if (clicou_em(_mx, _my, 1056, 656, 1118, 691)) {
            calc_operacao = 4;
        } else if (clicou_em(_mx, _my, 1126, 656, 1188, 691)) {
            calc_operacao = 5;
        } else if (clicou_em(_mx, _my, 1196, 656, 1258, 691)) {
            calc_operacao = 6;
        } else if (clicou_em(_mx, _my, 1266, 656, 1328, 691)) {
            calc_operacao = 7;
        } else {
            calc_foco = -1;
            keyboard_string = "";
        }
    }
}

// Rabiscos sao segmentos guardados em coordenadas GUI.
if (riscando) {
    if (!mouse_check_button(mb_left)) {
        riscando = false;
    } else if (_mx >= 1050 && _mx <= 1330 && _my >= 280 && _my <= 492) {
        if (array_length(anotacoes) < 3500) {
            array_push(anotacoes, {x1:risco_x, y1:risco_y, x2:_mx, y2:_my});
        }
        risco_x = _mx;
        risco_y = _my;
    } else {
        riscando = false;
    }
}

// Entrada numerica por teclado nativo do GameMaker.
if (aba == 1 && calc_foco >= 0) {
    var _entrada = keyboard_string;
    var _limpa = "";
    for (var _i = 1; _i <= min(14, string_length(_entrada)); _i++) {
        var _ch = string_char_at(_entrada, _i);
        if (string_pos(_ch, "0123456789.-") > 0) _limpa += _ch;
    }
    keyboard_string = _limpa;
    if (calc_foco == 0) calc_a = _limpa; else calc_b = _limpa;
}

if (estado == "resultado") {
    if (_clique && clicou_em(_mx, _my, 810, 669, 1001, 730)) avancar();
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) avancar();
    exit;
}

if (estado != "jogo") exit;

// Ajuste de resposta. A faixa do controle muda conforme o conceito.
if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_down) || mouse_wheel_down()) {
    mudar_resposta(-resposta_passo * (keyboard_check(vk_shift) ? 5 : 1));
}
if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(vk_up) || mouse_wheel_up()) {
    mudar_resposta(resposta_passo * (keyboard_check(vk_shift) ? 5 : 1));
}

if (_clique && clicou_em(_mx, _my, 299, 680, 751, 719)) {
    var _f = clamp((_mx - 305) / 435, 0, 1);
    resposta = clamp(round((resposta_min + _f * (resposta_max - resposta_min)) / resposta_passo) * resposta_passo, resposta_min, resposta_max);
}

if ((_clique && clicou_em(_mx, _my, 810, 669, 1001, 730))
    || keyboard_check_pressed(vk_space)
    || (keyboard_check_pressed(vk_enter) && calc_foco < 0)) {
    disparar();
}
