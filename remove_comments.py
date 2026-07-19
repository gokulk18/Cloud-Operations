from pathlib import Path
import re

root = Path(r"c:/Users/307383/Downloads/Task 2")
allowed_exts = {".hcl", ".tf", ".py", ".js", ".yml", ".yaml", ".md", ".json"}
ignore_dirs = {".git", "node_modules", "__pycache__", ".venv", "venv"}


def strip_comments(text: str, ext: str) -> str:
    if ext in {".json"}:
        return text

    lines = text.splitlines()
    result = []
    in_block = False
    for line in lines:
        if in_block:
            if "*/" in line:
                line = line.split("*/", 1)[0]
                in_block = False
            else:
                continue

        stripped = line.lstrip()
        if stripped.startswith("#") or stripped.startswith("//") or stripped.startswith("/*"):
            continue

        out = []
        i = 0
        state = "code"
        while i < len(line):
            ch = line[i]
            nxt = line[i + 1] if i + 1 < len(line) else ""

            if state == "single":
                out.append(ch)
                if ch == "\\" and i + 1 < len(line):
                    out.append(line[i + 1])
                    i += 2
                    continue
                if ch == "'":
                    state = "code"
                i += 1
                continue

            if state == "double":
                out.append(ch)
                if ch == "\\" and i + 1 < len(line):
                    out.append(line[i + 1])
                    i += 2
                    continue
                if ch == '"':
                    state = "code"
                i += 1
                continue

            if ch == "'":
                state = "single"
                out.append(ch)
                i += 1
                continue
            if ch == '"':
                state = "double"
                out.append(ch)
                i += 1
                continue

            if ch == "#":
                break
            if ch == "/" and nxt == "/":
                break
            if ch == "/" and nxt == "*":
                in_block = True
                i += 2
                continue
            out.append(ch)
            i += 1

        if state != "code":
            out.append("")

        result.append("".join(out).rstrip())

    return "\n".join(result) + ("\n" if text.endswith("\n") else "")


changed = []
for path in root.rglob("*"):
    if not path.is_file():
        continue
    if any(part in ignore_dirs for part in path.parts):
        continue
    if path.suffix.lower() not in allowed_exts:
        continue
    try:
        text = path.read_text(encoding="utf-8")
    except Exception:
        continue
    new_text = strip_comments(text, path.suffix.lower())
    if new_text != text:
        path.write_text(new_text, encoding="utf-8", newline="")
        changed.append(str(path.relative_to(root)))

print(f"updated {len(changed)} files")
for item in changed:
    print(item)
