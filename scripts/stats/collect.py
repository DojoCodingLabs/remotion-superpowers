#!/usr/bin/env python3
"""Append repo adoption stats to CSV files in an output directory.

GitHub keeps traffic for 14 days only, so this runs daily and merges by date.
Usage: GH_TOKEN=... python3 scripts/stats/collect.py <out-dir>
"""
import csv
import datetime as dt
import json
import os
import re
import sys
import urllib.request

REPO = os.environ.get("STATS_REPO", "DojoCodingLabs/remotion-superpowers")
SKILLS_URL = f"https://skills.sh/{REPO}"


def get(url, token=None):
    req = urllib.request.Request(url, headers={"User-Agent": "remotion-superpowers-stats"})
    if token:
        req.add_header("Authorization", f"Bearer {token}")
        req.add_header("Accept", "application/vnd.github+json")
    with urllib.request.urlopen(req, timeout=30) as r:
        return r.read().decode("utf-8")


def gh(path, token):
    return json.loads(get(f"https://api.github.com/repos/{REPO}{path}", token))


def skills_installs():
    # skills.sh has no API; read the "N total installs" text. None if the layout changes.
    try:
        html = get(SKILLS_URL)
    except Exception as e:
        print(f"warning: skills.sh unreachable: {e}", file=sys.stderr)
        return None
    m = re.search(r">([\d,]+)<!-- --> total installs", html) or re.search(
        r'\\"([\d,]+)\\",\\" total installs', html
    )
    if not m:
        print("warning: skills.sh install count not found", file=sys.stderr)
        return None
    return int(m.group(1).replace(",", ""))


def merge_daily(path, rows):
    # rows: {date: (count, uniques)}; newer data for the same date wins (today is partial).
    data = {}
    if os.path.exists(path):
        with open(path, newline="") as f:
            for r in csv.DictReader(f):
                data[r["date"]] = (r["count"], r["uniques"])
    data.update({d: (str(c), str(u)) for d, (c, u) in rows.items()})
    with open(path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["date", "count", "uniques"])
        for d in sorted(data):
            w.writerow([d, *data[d]])


def daily(payload, key):
    return {x["timestamp"][:10]: (x["count"], x["uniques"]) for x in payload[key]}


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else "stats"
    token = os.environ.get("GH_TOKEN")
    if not token:
        sys.exit("GH_TOKEN is required (traffic needs a token with Administration: read)")
    os.makedirs(out, exist_ok=True)
    today = dt.datetime.now(dt.timezone.utc).date().isoformat()

    merge_daily(f"{out}/clones.csv", daily(gh("/traffic/clones", token), "clones"))
    merge_daily(f"{out}/views.csv", daily(gh("/traffic/views", token), "views"))

    repo = gh("", token)
    release_downloads = sum(
        a["download_count"] for rel in gh("/releases?per_page=100", token) for a in rel["assets"]
    )
    snap_path = f"{out}/snapshot.csv"
    header = ["date", "stars", "forks", "watchers", "open_issues", "skills_sh_installs", "release_asset_downloads"]
    rows = {}
    if os.path.exists(snap_path):
        with open(snap_path, newline="") as f:
            rows = {r["date"]: r for r in csv.DictReader(f)}
    installs = skills_installs()
    rows[today] = {
        "date": today,
        "stars": repo["stargazers_count"],
        "forks": repo["forks_count"],
        "watchers": repo["subscribers_count"],
        "open_issues": repo["open_issues_count"],
        "skills_sh_installs": "" if installs is None else installs,
        "release_asset_downloads": release_downloads,
    }
    with open(snap_path, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=header)
        w.writeheader()
        for d in sorted(rows):
            w.writerow({k: rows[d].get(k, "") for k in header})

    os.makedirs(f"{out}/referrers", exist_ok=True)
    with open(f"{out}/referrers/{today}.json", "w") as f:
        json.dump(
            {"referrers": gh("/traffic/popular/referrers", token), "paths": gh("/traffic/popular/paths", token)},
            f, indent=2,
        )
    print(f"{today}: stars={repo['stargazers_count']} skills.sh={installs}")


if __name__ == "__main__":
    main()
