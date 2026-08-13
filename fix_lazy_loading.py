#!/usr/bin/env python3
r"""
fix_lazy_loading.py -- Ingersoll catalog widget lazy-loading patcher

Adds loading="lazy" decoding="async" to the diagram <img class="diagram-img">
tag in every widget HTML file under a folder, recursively (so it walks every
per-catalog subfolder -- 8-3200\, 8-3031\, 8-3112\, etc. -- in one pass).

Idempotent: safe to re-run. Already-patched files are reported and skipped,
never double-patched.

Nothing else in any file is touched -- only that one tag, only the two
missing attributes added to it.

USAGE
  Dry run (default -- scans and reports, writes nothing):
    python fix_lazy_loading.py "C:\\path\\to\\ingersoll-widget-html"

  Apply for real (backs up every file it changes first, then writes):
    python fix_lazy_loading.py "C:\\path\\to\\ingersoll-widget-html" --apply

Backups go to a sibling folder:
    ingersoll-widget-html_backup_before_lazy_fix\\
mirroring the original folder structure -- created only with --apply, and
only for files actually being changed.

Always run without --apply first, read the report, and only re-run with
--apply once the file list looks right.
"""

import argparse
import re
import shutil
import sys
from pathlib import Path

IMG_TAG_RE = re.compile(r'<img\b[^>]*\bclass="diagram-img"[^>]*>')


def patch_tag(tag: str):
    """Returns (new_tag, changed). Leaves already-patched tags untouched."""
    if 'loading=' in tag:
        return tag, False
    if tag.rstrip().endswith('/>'):
        new_tag = tag[:tag.rstrip().rfind('/>')].rstrip() + ' loading="lazy" decoding="async" />'
    else:
        new_tag = tag[:tag.rfind('>')].rstrip() + ' loading="lazy" decoding="async">'
    return new_tag, True


def process_file(path: Path):
    with open(path, 'r', encoding='utf-8', newline='') as fh:
        text = fh.read()
    matches = IMG_TAG_RE.findall(text)
    if not matches:
        return 'no_match', text, 0

    changed_count = 0

    def _sub(m):
        nonlocal changed_count
        new_tag, changed = patch_tag(m.group(0))
        if changed:
            changed_count += 1
        return new_tag

    new_text = IMG_TAG_RE.sub(_sub, text)
    if changed_count == 0:
        return 'already_patched', text, 0
    return 'patched', new_text, changed_count


def main():
    ap = argparse.ArgumentParser(
        description="Add loading=lazy/decoding=async to diagram images in Ingersoll widget HTML files."
    )
    ap.add_argument('folder', help='Root folder to scan recursively (e.g. ingersoll-widget-html)')
    ap.add_argument('--apply', action='store_true', help='Actually write changes (default is dry run / report only)')
    args = ap.parse_args()

    root = Path(args.folder)
    if not root.is_dir():
        print(f"ERROR: not a folder: {root}")
        sys.exit(1)

    backup_root = root.parent / (root.name + '_backup_before_lazy_fix')

    html_files = sorted(root.rglob('*.html'))
    if not html_files:
        print(f"No .html files found under {root}")
        sys.exit(0)

    patched, already, no_match, errors = [], [], [], []

    for f in html_files:
        try:
            status, new_text, count = process_file(f)
        except Exception as e:
            errors.append((f, str(e)))
            continue

        rel = f.relative_to(root)
        if status == 'no_match':
            no_match.append(rel)
        elif status == 'already_patched':
            already.append(rel)
        else:
            patched.append((rel, count))
            if args.apply:
                backup_path = backup_root / rel
                backup_path.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(f, backup_path)
                with open(f, 'w', encoding='utf-8', newline='') as fh:
                    fh.write(new_text)

    mode = "APPLIED" if args.apply else "DRY RUN -- no files were changed"
    print(f"\n=== {mode} ===")
    print(f"Scanned: {len(html_files)} file(s) under {root}\n")

    print(f"Patched: {len(patched)}")
    for rel, count in patched:
        mark = 'x' if args.apply else ' '
        plural = 's' if count != 1 else ''
        print(f"  [{mark}] {rel}  ({count} img tag{plural})")

    if already:
        print(f"\nAlready patched, skipped: {len(already)}")
        for rel in already:
            print(f"  - {rel}")

    if no_match:
        print(f"\nWARNING -- no diagram-img tag found, needs manual review: {len(no_match)}")
        for rel in no_match:
            print(f"  ! {rel}")

    if errors:
        print(f"\nERRORS reading/writing: {len(errors)}")
        for f, e in errors:
            print(f"  !! {f}: {e}")

    if not args.apply and patched:
        print(f"\nThis was a dry run -- nothing was written.")
        print(f"Re-run with --apply once this list looks right.")
        print(f"Backups of every changed file will be saved to:\n  {backup_root}")

    if args.apply and patched:
        print(f"\nDone. {len(patched)} file(s) updated. Backups saved to:\n  {backup_root}")


if __name__ == '__main__':
    main()
