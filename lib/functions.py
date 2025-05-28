from pathlib import Path

def extra_spellfiles():
    for p in sorted((Path.home() / ".vim" / "spell").glob("*.add")):
        if p.name != "words.utf-8.add":
            yield p.name
