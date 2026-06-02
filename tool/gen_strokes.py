#!/usr/bin/env python3
"""書き順データ生成スクリプト。

かな（ひらがな・カタカナ、だくてん・半だくてん・小書き・拗音）は KanjiVG
(https://kanjivg.tagaini.net/, CC BY-SA 3.0) の 1 画ずつの SVG パス
(センターライン, 109x109 viewBox) から抽出する。
アルファベット 52 字は KanjiVG に無いため手書きで定義する（同じ 109x109 座標系）。

出力: assets/strokes/{hiragana,katakana,alphabet_upper,alphabet_lower}.json
使用した KanjiVG の SVG は tool/kanjivg_src/ にコピーして再現性を確保する。

実行例:
  python3 tool/gen_strokes.py /path/to/kanjivg
KanjiVG のパスを省略した場合は tool/kanjivg_src/ を参照する。
"""

import json
import os
import re
import sys
import shutil
import xml.etree.ElementTree as ET

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(ROOT, "assets", "strokes")
VENDOR_DIR = os.path.join(ROOT, "tool", "kanjivg_src")
VIEWBOX = 109

# ---------------------------------------------------------------------------
# 文字定義（かな）
# ---------------------------------------------------------------------------

HIRAGANA_BASIC = list(
    "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん"
)
HIRAGANA_DAKUTEN = list("がぎぐげござじずぜぞだぢづでどばびぶべぼ")
HIRAGANA_HANDAKUTEN = list("ぱぴぷぺぽ")
HIRAGANA_SMALL = list("ゃゅょっ")

KATAKANA_BASIC = list(
    "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン"
)
KATAKANA_DAKUTEN = list("ガギグゲゴザジズゼゾダヂヅデドバビブベボ")
KATAKANA_HANDAKUTEN = list("パピプペポ")
KATAKANA_SMALL = list("ャュョッ")

# 拗音（親かな + 小書きかな）。
HIRA_YOON_PARENTS = list("きしちにひみりぎじびぴ")
KATA_YOON_PARENTS = list("キシチニヒミリギジビピ")
HIRA_SMALL_Y = list("ゃゅょ")
KATA_SMALL_Y = list("ャュョ")

# ---------------------------------------------------------------------------
# SVG パス変換（拗音の合成用）。絶対コマンドはアフィン、相対コマンドはスケールのみ。
# ---------------------------------------------------------------------------

_TOKEN_RE = re.compile(r"[MmLlHhVvCcSsQqTtAaZz]|-?\d*\.?\d+(?:[eE][-+]?\d+)?")


def transform_path(d, s, dx, dy):
    """パス d を scale s, translate (dx, dy) で変換した新しい d を返す。"""
    tokens = _TOKEN_RE.findall(d)
    out = []
    i = 0
    n = len(tokens)

    def num(idx):
        return float(tokens[idx])

    while i < n:
        cmd = tokens[i]
        i += 1
        if cmd in "Zz":
            out.append(cmd)
            continue
        out.append(cmd)
        absolute = cmd.isupper()
        c = cmd.upper()
        if c in ("H",):
            x = num(i); i += 1
            out.append(_fmt(x * s + dx if absolute else x * s))
        elif c in ("V",):
            y = num(i); i += 1
            out.append(_fmt(y * s + dy if absolute else y * s))
        elif c == "A":
            # rx ry rot large sweep x y
            rx = num(i); ry = num(i + 1); rot = tokens[i + 2]
            large = tokens[i + 3]; sweep = tokens[i + 4]
            x = num(i + 5); y = num(i + 6)
            i += 7
            out.extend([
                _fmt(rx * s), _fmt(ry * s), rot, large, sweep,
                _fmt(x * s + dx if absolute else x * s),
                _fmt(y * s + dy if absolute else y * s),
            ])
        else:
            # M L T (2), C (6), S Q (4) -> すべて (x, y) ペアの並び
            # 残りの数値を 2 個ずつ消費する（暗黙の連続コマンドに対応）。
            pair_count = {"M": 1, "L": 1, "T": 1, "C": 3, "S": 2, "Q": 2}[c]
            params = pair_count * 2
            while i + 1 < n and not tokens[i].lstrip("-").replace(".", "", 1)[:1].isalpha():
                # まとめて params 個取り出す
                group = tokens[i:i + params]
                if len(group) < params:
                    break
                for k in range(0, params, 2):
                    x = float(group[k]); y = float(group[k + 1])
                    out.append(_fmt(x * s + dx if absolute else x * s))
                    out.append(_fmt(y * s + dy if absolute else y * s))
                i += params
                # M の 2 ペア目以降は L 扱い、相対も同様。最初以外は translate なしの
                # 絶対判定は cmd 由来のまま（KanjiVG は M の後すぐ c なので実害なし）。
    return " ".join(out)


def _fmt(v):
    return ("%.2f" % v).rstrip("0").rstrip(".")


# ---------------------------------------------------------------------------
# KanjiVG SVG 読み込み
# ---------------------------------------------------------------------------

_used_files = []


def kvg_filename(ch):
    return "%05x.svg" % ord(ch)


def load_strokes(ch, kvg_dir):
    """文字 ch の画パス d 文字列のリストを描き順で返す。"""
    fn = kvg_filename(ch)
    path = os.path.join(kvg_dir, fn)
    if not os.path.exists(path):
        raise FileNotFoundError("KanjiVG に %s (%s) がありません" % (ch, fn))
    _used_files.append(path)
    tree = ET.parse(path)
    root = tree.getroot()
    ns = {"svg": "http://www.w3.org/2000/svg"}
    ds = []
    for p in root.iter("{http://www.w3.org/2000/svg}path"):
        d = p.get("d")
        if d:
            ds.append(d.strip())
    if not ds:
        raise ValueError("%s に path がありません" % ch)
    return ds


# ---------------------------------------------------------------------------
# エントリ作成
# ---------------------------------------------------------------------------


def cp_key(ch):
    return "U+%04X" % ord(ch)


def simple_entry(ch, category, kvg_dir):
    return {
        "char": ch,
        "label": ch,
        "key": cp_key(ch),
        "category": category,
        "viewBox": VIEWBOX,
        "strokes": load_strokes(ch, kvg_dir),
    }


def yoon_entry(parent, small, category, kvg_dir):
    """拗音タイル。親かなを左 62%、小書きかなを右下 46% に配置して画を連結する。"""
    parent_strokes = load_strokes(parent, kvg_dir)
    small_strokes = load_strokes(small, kvg_dir)
    p = [transform_path(d, 0.62, 2.0, 20.7) for d in parent_strokes]
    sm = [transform_path(d, 0.46, 55.0, 53.0) for d in small_strokes]
    ch = parent + small
    return {
        "char": ch,
        "label": ch,
        "key": "%s_%s" % (cp_key(parent), cp_key(small)),
        "category": category,
        "viewBox": VIEWBOX,
        "strokes": p + sm,
    }


# ---------------------------------------------------------------------------
# アルファベット（手書き定義, 109x109）
# 大文字: top=20, mid=56, bottom=92, left=32, right=77, cx=54.5
# 小文字: ascender=18, x-top=46, baseline=92, descender=105, cx=53.5
# ---------------------------------------------------------------------------

LATIN_UPPER = {
    "A": ["M54.5,20 L33,92", "M54.5,20 L76,92", "M41,64 L68,64"],
    "B": ["M37,20 L37,92", "M37,20 L58,20 A16,16 0 0 1 58,56 L37,56",
          "M37,56 L62,56 A18,18 0 0 1 62,92 L37,92"],
    "C": ["M73,38 A26,26 0 1 0 73,74"],
    "D": ["M37,20 L37,92", "M37,20 L52,20 A36,36 0 0 1 52,92 L37,92"],
    "E": ["M37,20 L37,92", "M37,20 L73,20", "M37,56 L66,56", "M37,92 L73,92"],
    "F": ["M37,20 L37,92", "M37,20 L73,20", "M37,56 L66,56"],
    "G": ["M73,40 A26,26 0 1 0 73,73", "M73,73 L73,58 L60,58"],
    "H": ["M37,20 L37,92", "M72,20 L72,92", "M37,56 L72,56"],
    "I": ["M54.5,20 L54.5,92"],
    "J": ["M62,20 L62,76 A15,15 0 0 1 32,76"],
    "K": ["M37,20 L37,92", "M72,20 L37,58", "M47,50 L74,92"],
    "L": ["M37,20 L37,92 L72,92"],
    "M": ["M33,92 L33,20 L54.5,64 L76,20 L76,92"],
    "N": ["M37,92 L37,20 L72,92 L72,20"],
    "O": ["M54.5,20 A24,36 0 0 0 54.5,92 A24,36 0 0 0 54.5,20"],
    "P": ["M37,20 L37,92", "M37,20 L58,20 A17,17 0 0 1 58,54 L37,54"],
    "Q": ["M54.5,20 A24,36 0 0 0 54.5,92 A24,36 0 0 0 54.5,20", "M60,74 L80,96"],
    "R": ["M37,20 L37,92", "M37,20 L58,20 A17,17 0 0 1 58,54 L37,54", "M50,54 L74,92"],
    "S": ["M73,36 C73,22 50,20 42,30 C33,42 50,52 56,58 C66,66 60,86 38,80"],
    "T": ["M30,20 L79,20", "M54.5,20 L54.5,92"],
    "U": ["M35,20 L35,72 A19.5,19.5 0 0 0 74,72 L74,20"],
    "V": ["M33,20 L54.5,92 L76,20"],
    "W": ["M30,20 L42,92 L54.5,40 L67,92 L79,20"],
    "X": ["M35,20 L74,92", "M74,20 L35,92"],
    "Y": ["M35,20 L54.5,56", "M74,20 L54.5,56", "M54.5,56 L54.5,92"],
    "Z": ["M34,20 L75,20 L34,92 L75,92"],
}

LATIN_LOWER = {
    "a": ["M71,49 A20,23 0 1 0 71,90", "M71,45 L71,92"],
    "b": ["M36,18 L36,92", "M36,55 A19,18 0 1 1 36,90"],
    "c": ["M71,54 A21,21 0 1 0 71,86"],
    "d": ["M71,52 A19,19 0 1 0 71,86", "M71,18 L71,92"],
    "e": ["M37,68 L70,68 C73,53 61,45 50,45 C36,45 33,58 33,69 C33,84 46,90 64,83"],
    "f": ["M71,30 C71,20 52,18 47,28 L47,92", "M33,50 L63,50"],
    "g": ["M71,52 A19,18 0 1 0 71,86", "M71,48 L71,96 A16,12 0 0 1 44,100"],
    "h": ["M37,18 L37,92", "M37,58 A18,16 0 0 1 71,66 L71,92"],
    "i": ["M53,46 L53,92", "M53,30 L53,33"],
    "j": ["M61,46 L61,96 A15,12 0 0 1 36,98", "M61,30 L61,33"],
    "k": ["M38,18 L38,92", "M70,52 L40,72", "M48,66 L72,92"],
    "l": ["M53,18 L53,92"],
    "m": ["M36,46 L36,92", "M36,58 A14,12 0 0 1 55,62 L55,92",
          "M55,58 A14,12 0 0 1 74,62 L74,92"],
    "n": ["M37,46 L37,92", "M37,58 A18,16 0 0 1 71,66 L71,92"],
    "o": ["M53.5,46 A20,23 0 0 0 53.5,92 A20,23 0 0 0 53.5,46"],
    "p": ["M37,46 L37,105", "M37,55 A19,18 0 1 1 37,90"],
    "q": ["M71,52 A19,18 0 1 0 71,86", "M71,46 L71,105"],
    "r": ["M40,46 L40,92", "M40,60 A16,14 0 0 1 68,56"],
    "s": ["M70,52 C70,44 48,44 44,52 C40,60 64,66 62,76 C60,86 40,86 36,78"],
    "t": ["M50,28 L50,84 A12,10 0 0 0 70,86", "M36,48 L66,48"],
    "u": ["M37,46 L37,78 A18,16 0 0 0 71,78 L71,46", "M71,46 L71,92"],
    "v": ["M36,46 L53.5,92 L71,46"],
    "w": ["M33,46 L43,92 L53.5,58 L64,92 L74,46"],
    "x": ["M37,46 L71,92", "M71,46 L37,92"],
    "y": ["M37,46 L53.5,84", "M71,46 L40,105"],
    "z": ["M36,46 L71,46 L36,92 L71,92"],
}


def latin_entry(ch, strokes, category):
    return {
        "char": ch,
        "label": ch,
        "key": cp_key(ch),
        "category": category,
        "viewBox": VIEWBOX,
        "strokes": strokes,
    }


# ---------------------------------------------------------------------------
# メイン
# ---------------------------------------------------------------------------


def build_hiragana(kvg_dir):
    out = []
    for ch in HIRAGANA_BASIC:
        out.append(simple_entry(ch, "hiragana", kvg_dir))
    for ch in HIRAGANA_DAKUTEN + HIRAGANA_HANDAKUTEN:
        out.append(simple_entry(ch, "hiragana", kvg_dir))
    for ch in HIRAGANA_SMALL:
        out.append(simple_entry(ch, "hiragana", kvg_dir))
    for parent in HIRA_YOON_PARENTS:
        for small in HIRA_SMALL_Y:
            out.append(yoon_entry(parent, small, "hiragana", kvg_dir))
    return out


def build_katakana(kvg_dir):
    out = []
    for ch in KATAKANA_BASIC:
        out.append(simple_entry(ch, "katakana", kvg_dir))
    for ch in KATAKANA_DAKUTEN + KATAKANA_HANDAKUTEN:
        out.append(simple_entry(ch, "katakana", kvg_dir))
    for ch in KATAKANA_SMALL:
        out.append(simple_entry(ch, "katakana", kvg_dir))
    for parent in KATA_YOON_PARENTS:
        for small in KATA_SMALL_Y:
            out.append(yoon_entry(parent, small, "katakana", kvg_dir))
    return out


def main():
    kvg_dir = sys.argv[1] if len(sys.argv) > 1 else os.path.join(VENDOR_DIR, "kanji")
    if not os.path.isdir(kvg_dir):
        print("KanjiVG ディレクトリが見つかりません: %s" % kvg_dir)
        sys.exit(1)

    os.makedirs(OUT_DIR, exist_ok=True)

    data = {
        "hiragana": build_hiragana(kvg_dir),
        "katakana": build_katakana(kvg_dir),
        "alphabet_upper": [latin_entry(c, LATIN_UPPER[c], "alphabet_upper")
                           for c in sorted(LATIN_UPPER)],
        "alphabet_lower": [latin_entry(c, LATIN_LOWER[c], "alphabet_lower")
                           for c in sorted(LATIN_LOWER)],
    }

    for name, entries in data.items():
        # 検証: 各エントリは 1 画以上、キーは一意。
        keys = set()
        for e in entries:
            assert e["strokes"], "%s に画がありません" % e["char"]
            assert e["key"] not in keys, "キー重複: %s" % e["key"]
            keys.add(e["key"])
        path = os.path.join(OUT_DIR, name + ".json")
        with open(path, "w", encoding="utf-8") as f:
            json.dump(entries, f, ensure_ascii=False, indent=1)
        print("書き出し: %s (%d 文字)" % (path, len(entries)))

    # 使用した KanjiVG SVG をベンダリング（再現性とライセンス遵守）。
    vendor_kanji = os.path.join(VENDOR_DIR, "kanji")
    os.makedirs(vendor_kanji, exist_ok=True)
    for src in sorted(set(_used_files)):
        dst = os.path.join(vendor_kanji, os.path.basename(src))
        if os.path.abspath(src) != os.path.abspath(dst):
            shutil.copyfile(src, dst)
    print("KanjiVG SVG を %d 件ベンダリング: %s" % (len(set(_used_files)), vendor_kanji))


if __name__ == "__main__":
    main()
