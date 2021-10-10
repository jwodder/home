from pathlib import Path

def extra_spellfiles():
    for p in sorted((Path.home() / "share" / "spell").glob("*.add")):
        if p.name != "words.utf-8.add":
            yield p.name
