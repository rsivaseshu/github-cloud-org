# Optional helper: sync_labels.py
# Usage: pip install PyGithub
#        export GITHUB_TOKEN=... && python3 sync_labels.py --org myorg --repo service-a --from-file labels.json
import argparse
import json
import os
from github import Github

def load_labels(path):
    with open(path) as f:
        return json.load(f)

def sync_labels(org, repo, token, labels):
    gh = Github(token)
    repo_obj = gh.get_organization(org).get_repo(repo)
    existing = {l.name: l for l in repo_obj.get_labels()}
    for l in labels:
        name = l['name']
        color = l.get('color', 'ededed')
        desc = l.get('description', '')
        if name in existing:
            existing[name].edit(name, color, desc)
            print(f"Updated label {name}")
        else:
            repo_obj.create_label(name, color, desc)
            print(f"Created label {name}")

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--org', required=True)
    p.add_argument('--repo', required=True)
    p.add_argument('--token', default=None)
    p.add_argument('--from-file', required=True, dest='file')
    args = p.parse_args()
    token = args.token or os.environ.get('GITHUB_TOKEN')
    if not token:
        raise SystemExit('GITHUB_TOKEN required')
    labels = load_labels(args.file)
    sync_labels(args.org, args.repo, token, labels)

if __name__ == '__main__':
    main()
