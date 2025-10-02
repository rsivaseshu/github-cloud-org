#!/usr/bin/env python3
"""
Simple renderer for the `codeowners` block in envs/*/terraform.tfvars.
This is a lightweight parser that expects reasonably formatted HCL-like tfvars (strings, lists, maps).

Run from repo root:
  python tools/render_codeowners.py envs/prod/terraform.tfvars

It prints the CODEOWNERS content that the module would write for each block.
"""
import sys
import re


def read_block(text, start_idx):
    # Read balanced braces block starting at the first '{' after start_idx
    i = text.find('{', start_idx)
    if i == -1:
        return None, start_idx
    depth = 0
    for j in range(i, len(text)):
        if text[j] == '{':
            depth += 1
        elif text[j] == '}':
            depth -= 1
            if depth == 0:
                return text[i+1:j], j+1
    return None, start_idx


def parse_list(s):
    # parse a list like ["a","b"] or ['a', 'b']
    items = re.findall(r"['\"]([^'\"]+)['\"]", s)
    return [it.strip() for it in items]


def parse_entries_block(s):
    # expects map of path = [owners]
    entries = {}
    # iterate lines
    for line in s.splitlines():
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        m = re.match(r"['\"]?(.+?)['\"]?\s*=\s*\[(.*)\]", line)
        if m:
            path = m.group(1).strip()
            owners_raw = m.group(2)
            owners = parse_list('[' + owners_raw + ']')
            entries[path] = owners
    return entries


def parse_codeowners_block(block_text):
    # find repository and entries block
    repo = None
    entries = {}
    # find repository = "..."
    m = re.search(r'repository\s*=\s*["\']([^"\']+)["\']', block_text)
    if m:
        repo = m.group(1)
    # find entries = { ... }
    ent_pos = block_text.find('entries')
    if ent_pos != -1:
        entries_block, _ = read_block(block_text, ent_pos)
        if entries_block is not None:
            entries = parse_entries_block(entries_block)
    return repo, entries


def find_codeowners(tfvars_text):
    results = {}
    # find top-level codeowners = { ... }
    idx = tfvars_text.find('codeowners')
    if idx == -1:
        return results
    top_block, _ = read_block(tfvars_text, idx)
    if not top_block:
        return results
    # Now parse each named block inside top_block like name = { ... }
    i = 0
    while i < len(top_block):
        # find an identifier
        m = re.search(r"([a-zA-Z0-9_\-]+)\s*=\s*\{", top_block[i:])
        if not m:
            break
        name = m.group(1)
        start = i + m.start()
        content, next_idx = read_block(top_block, start)
        if content is None:
            break
        repo, entries = parse_codeowners_block(content)
        results[name] = {'repository': repo, 'entries': entries}
        i = next_idx
    return results


def render_codeowners_block(block):
    lines = []
    for path, owners in block['entries'].items():
        owner_str = ' '.join(['@' + o for o in owners])
        lines.append(f"{path} {owner_str}")
    return '\n'.join(lines)


def main():
    if len(sys.argv) < 2:
        print('Usage: render_codeowners.py <path-to-terraform.tfvars>')
        sys.exit(2)
    path = sys.argv[1]
    txt = open(path, 'r', encoding='utf-8').read()
    blocks = find_codeowners(txt)
    if not blocks:
        print('No codeowners block found in', path)
        return
    for name, block in blocks.items():
        print('--- CODEOWNERS for', name, '-> repo:', block['repository'])
        print(render_codeowners_block(block))
        print()


if __name__ == '__main__':
    main()
