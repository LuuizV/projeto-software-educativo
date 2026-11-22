/// @description Estado central e problemas do MVP - Fisica em Acao
/// Uma unica instancia controla o jogo. Sem dependencias externas.
randomize();

gui_w = 1366;
gui_h = 768;
display_set_gui_size(gui_w, gui_h);

cor_fundo = make_color_rgb(12, 17, 35);
cor_painel = make_color_rgb(23, 31, 55);
cor_painel_claro = make_color_rgb(33, 45, 76);
cor_azul = make_color_rgb(83, 164, 235);
cor_amarelo = make_color_rgb(255, 198, 69);
cor_verde = make_color_rgb(90, 216, 148);
cor_vermelho = make_color_rgb(250, 117, 115);
cor_texto = make_color_rgb(236, 240, 250);
cor_suave = make_color_rgb(168, 181, 207);

gravidade = 9.8;
estado = "menu";
estado_pausado = "jogo";
iniciado = false;
modulo = 0;
modulo_menu = 0;
desbloqueado = 0;
pontos = 0;
sequencia = 0;
questao = 0;
tentativas = 0;
tolerancia = 2;
cenario = {};
resposta = 30;
resposta_passo = 1;
resposta_min = 5;
resposta_max = 45;
aba = 0; // 0: teoria, 1: caderno
resultado_acerto = false;
erro_metros = 0;
alcance_real = 0;
tempo_tiro = 0;
tempo_final = 1;
velocidade_sim = 1;
usou_dica = false;
mensagem_dica = "";
anotacoes = [];
riscando = false;
risco_x = 0;
risco_y = 0;
calc_a = "";
calc_b = "";
calc_operacao = 0;
calc_foco = -1; // -1: teclado livre, 0: campo A, 1: campo B

ini_open("fisica_em_acao.ini");
desbloqueado = clamp(ini_read_real("progresso", "modulo_desbloqueado", 0), 0, 2);
pontos = max(0, ini_read_real("progresso", "recorde_pontos", 0));
ini_close();
modulo_menu = desbloqueado;

salvar_progresso = function() {
    ini_open("fisica_em_acao.ini");
    ini_write_real("progresso", "modulo_desbloqueado", desbloqueado);
    ini_write_real("progresso", "recorde_pontos", pontos);
    ini_close();
};

nome_modulo = function(_i) {
    switch (_i) {
        case 0: return "Lancamento obliquo";
        case 1: return "Lancamento horizontal";
        default: return "Frenagem (MRUV)";
    }
};

nome_variavel = function() {
    switch (modulo) {
        case 0: return "Angulo do canhao";
        case 1: return "Velocidade horizontal";
        default: return "Desaceleracao";
    }
};

unidade_variavel = function() {
    switch (modulo) {
        case 0: return "graus";
        case 1: return "m/s";
        default: return "m/s2";
    }
};

formatar_numero = function(_numero, _decimais) {
    var _potencia = power(10, _decimais);
    return string(round(_numero * _potencia) / _potencia);
};

iniciar_questao = function() {
    var _n = questao mod 6;
    var _v, _h, _a, _d;

    switch (modulo) {
        case 0:
            var _vel = [25, 28, 30, 23, 31, 27];
            var _ang = [22, 28, 35, 18, 32, 40];
            _v = _vel[_n];
            _a = _ang[_n];
            _d = sqr(_v) * dsin(2 * _a) / gravidade;
            cenario = {tipo:0, velocidade:_v, altura:0, aceleracao:0, distancia:_d, solucao:_a};
            resposta_min = 5;
            resposta_max = 45;
            resposta_passo = 1;
            resposta = 30;
            break;
        case 1:
            var _alturas = [12, 20, 16, 26, 14, 18];
            var _vxs = [12, 15, 20, 18, 23, 26];
            _h = _alturas[_n];
            _v = _vxs[_n];
            _d = _v * sqrt(2 * _h / gravidade);
            cenario = {tipo:1, velocidade:_v, altura:_h, aceleracao:0, distancia:_d, solucao:_v};
            resposta_min = 4;
            resposta_max = 40;
            resposta_passo = 1;
            resposta = 16;
            break;
        default:
            var _vel_freio = [18, 22, 25, 20, 24, 28];
            var _desacel = [4, 5, 6, 5, 8, 7];
            _v = _vel_freio[_n];
            _a = _desacel[_n];
            _d = sqr(_v) / (2 * _a);
            cenario = {tipo:2, velocidade:_v, altura:0, aceleracao:_a, distancia:_d, solucao:_a};
            resposta_min = 1;
            resposta_max = 12;
            resposta_passo = 0.5;
            resposta = 5;
    }

    tentativas = 0;
    tempo_tiro = 0;
    tempo_final = 1;
    alcance_real = 0;
    erro_metros = 0;
    resultado_acerto = false;
    usou_dica = false;
    mensagem_dica = "";
    anotacoes = [];
    riscando = false;
    calc_a = "";
    calc_b = "";
    calc_foco = -1;
    keyboard_string = "";
};

iniciar_modulo = function(_i) {
    modulo = clamp(_i, 0, 2);
    iniciado = true;
    sequencia = 0;
    questao = 0;
    aba = 0;
    velocidade_sim = 1;
    iniciar_questao();
    estado = "jogo";
};

mudar_resposta = function(_d) {
    resposta = clamp(round((resposta + _d) / resposta_passo) * resposta_passo, resposta_min, resposta_max);
};

disparar = function() {
    if (estado != "jogo") return;
    tempo_tiro = 0;
    if (modulo == 0) {
        tempo_final = 2 * cenario.velocidade * dsin(resposta) / gravidade;
        alcance_real = sqr(cenario.velocidade) * dsin(2 * resposta) / gravidade;
    } else if (modulo == 1) {
        tempo_final = sqrt(2 * cenario.altura / gravidade);
        alcance_real = resposta * tempo_final;
    } else {
        tempo_final = cenario.velocidade / max(resposta, 0.1);
        alcance_real = sqr(cenario.velocidade) / (2 * resposta);
    }
    tempo_final = max(0.05, tempo_final);
    erro_metros = abs(alcance_real - cenario.distancia);
    estado = "simulacao";
};

terminar_disparo = function() {
    tentativas += 1;
    resultado_acerto = erro_metros <= tolerancia;
    if (resultado_acerto) {
        sequencia += 1;
        pontos += max(40, 120 - (tentativas - 1) * 40);
        salvar_progresso();
    } else {
        sequencia = 0;
    }
    estado = "resultado";
};

avancar = function() {
    if (estado != "resultado") return;
    if (resultado_acerto && sequencia >= 3) {
        if (modulo < 2) {
            desbloqueado = max(desbloqueado, modulo + 1);
            salvar_progresso();
            estado = "modulo_concluido";
        } else {
            salvar_progresso();
            estado = "jogo_concluido";
        }
        return;
    }

    if (!resultado_acerto && tentativas < 3) {
        tempo_tiro = 0;
        estado = "jogo";
        return;
    }

    questao += 1;
    iniciar_questao();
    estado = "jogo";
};

clicou_em = function(_px, _py, _x1, _y1, _x2, _y2) {
    return (_px >= _x1 && _px <= _x2 && _py >= _y1 && _py <= _y2);
};

campo_numerico_valido = function(_s) {
    var _len = string_length(_s);
    if (_len == 0 || _s == "-" || _s == "." || _s == "-.") return false;
    var _pontos = 0;
    for (var _i = 1; _i <= _len; _i++) {
        var _car = string_char_at(_s, _i);
        if (_car == ".") {
            _pontos += 1;
            if (_pontos > 1) return false;
        } else if (_car == "-") {
            if (_i != 1) return false;
        } else if (string_pos(_car, "0123456789") <= 0) {
            return false;
        }
    }
    return true;
};

resultado_calculadora = function() {
    if (!campo_numerico_valido(calc_a)) return "Digite o numero A";
    var _a = real(calc_a);
    var _r = 0;
    if (calc_operacao >= 4) {
        // Funcoes cientificas: seno e arco-seno trabalham em graus.
        switch (calc_operacao) {
            case 4: _r = dsin(_a); break;
            case 5:
                if (abs(_a) > 1) return "asin exige -1 a 1";
                _r = darcsin(_a);
                break;
            case 6:
                if (_a < 0) return "Raiz de negativo";
                _r = sqrt(_a);
                break;
            case 7: _r = sqr(_a); break;
        }
        return formatar_numero(_r, 4);
    }

    if (!campo_numerico_valido(calc_b)) return "Digite o numero B";
    var _b = real(calc_b);
    switch (calc_operacao) {
        case 0: _r = _a + _b; break;
        case 1: _r = _a - _b; break;
        case 2: _r = _a * _b; break;
        case 3:
            if (abs(_b) < 0.0000001) return "Divisao por zero";
            _r = _a / _b;
            break;
    }
    return formatar_numero(_r, 4);
};
