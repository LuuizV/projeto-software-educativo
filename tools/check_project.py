#!/usr/bin/env python3
"""Confere referencias estruturais do projeto GameMaker sem depender do editor."""
from __future__ import annotations
import json
import math
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "projeto-software-educativo"
PROJECT = ROOT / "projeto-software-educativo.yyp"


def yy(path: Path):
    text = path.read_text(encoding="utf-8-sig")
    # GameMaker admite virgulas finais em arquivos .yy e .yyp.
    text = re.sub(r",(\s*[}\]])", r"\1", text)
    return json.loads(text)


def check():
    project = yy(PROJECT)
    resources = project["resources"]
    assert resources, "Sem recursos registrados no projeto"
    objects = {}
    rooms = {}
    for entry in resources:
        res_id = entry["id"]
        path = ROOT / res_id["path"]
        assert path.is_file(), f"Recurso sem arquivo: {path}"
        item = yy(path)
        assert item["name"] == res_id["name"], f"Nome incorreto: {path}"
        if item["resourceType"] == "GMObject":
            objects[res_id["name"]] = item
            directory = path.parent
            for ev in item["eventList"]:
                kind = ev["eventType"]
                num = ev["eventNum"]
                event_file = {
                    (0, 0): "Create_0.gml",
                    (3, 0): "Step_0.gml",
                    (8, 64): "Draw_64.gml",
                }.get((kind, num))
                if event_file:
                    assert (directory / event_file).is_file(), f"Falta {directory / event_file}"
        elif item["resourceType"] == "GMRoom":
            rooms[res_id["name"]] = item

    assert "obj_fisica" in objects, "Controlador nao registrado"
    assert "Room1" in rooms, "Sala inicial nao encontrada"
    instances = [
        inst
        for layer in rooms["Room1"]["layers"]
        for inst in layer.get("instances", [])
    ]
    # O serializador do GameMaker exige frozen em cada GMRInstance.
    # Ter JSON sintaticamente valido nao garante que o editor consiga carregar.
    for instance in instances:
        assert instance.get("$GMRInstance") is not None, "Instancia sem identificador GMRInstance"
        assert "frozen" in instance and type(instance["frozen"]) is bool, (
            f"Campo frozen ausente/invalido: {instance.get('name', 'sem nome')}"
        )
        assert "creationCodeFile" not in instance, (
            f"Campo nao pertencente ao GMRInstance: {instance.get('name', 'sem nome')}"
        )
    active = [i for i in instances if i["objectId"]["name"] == "obj_fisica"]
    assert len(active) == 1, "Room1 deve conter exatamente um obj_fisica"
    order = {e["name"] for e in rooms["Room1"]["instanceCreationOrder"]}
    assert active[0]["name"] in order, "Instancia nao registrada na ordem da sala"

    # GameMaker nao captura variaveis locais de funcoes anonimas aninhadas.
    # A antiga _botao chamava os helpers _caixa/_texto e quebrava no Draw.
    draw_code = (ROOT / "objects" / "obj_fisica" / "Draw_64.gml").read_text(encoding="utf-8")
    import re
    button_match = re.search(r"var _botao\s*=\s*function\([^)]*\)\s*\{(.*?)\n\};", draw_code, re.S)
    assert button_match, "Funcao _botao ausente"
    button_body = button_match.group(1)
    assert "_caixa(" not in button_body and "_texto(" not in button_body, (
        "_botao nao pode chamar helpers locais; faltara variavel no runtime do GML"
    )

    # Valida a matematica dos primeiros problemas, sem declarar compilacao GML.
    g = 9.8
    oblique_range = (25**2 * math.sin(math.radians(44))) / g
    horizontal_range = 12 * math.sqrt(2 * 12 / g)
    stopping_distance = 18**2 / (2 * 4)
    assert abs(oblique_range - 44.3021919936) < 1e-5
    assert abs(horizontal_range - 18.7790591145) < 1e-5
    assert abs(stopping_distance - 40.5) < 1e-8
    print("OK: metadados GameMaker, registros de eventos, Room1 e formulas-base.")


if __name__ == "__main__":
    check()
