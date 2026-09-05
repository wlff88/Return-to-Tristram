"""Read-only installation metadata probe. This does not load HD assets."""
import argparse
import csv
import hashlib
import io
import json
import os
from pathlib import Path
import re


def inspect_install(root):
    root = Path(root).expanduser().resolve(strict=True)
    if not root.is_dir() or not (root / 'D2R.exe').is_file() or not (root / 'Data').is_dir():
        raise ValueError('Expected D2R.exe, Data/ and .build.info in the installation root')
    metadata = root / '.build.info'
    if metadata.stat().st_size > 1024 * 1024:
        raise ValueError('Build metadata exceeds 1 MiB')
    rows = list(csv.reader(io.StringIO(metadata.read_text(encoding='utf-8-sig')), delimiter='|'))
    if not rows:
        raise ValueError('Empty build metadata')
    keys = [key.split('!', 1)[0] for key in rows[0]]
    if len(set(keys)) != len(keys) or not {'Active', 'Build Key', 'Version'} <= set(keys):
        raise ValueError('Unsupported build metadata columns')
    active = []
    for values in rows[1:]:
        if not values:
            continue
        if len(values) != len(keys):
            raise ValueError('Malformed build metadata row')
        row = dict(zip(keys, values))
        if row['Active'] == '1':
            active.append(row)
    if len(active) != 1:
        raise ValueError('Expected exactly one active installation build')
    row = active[0]
    if not re.fullmatch(r'[0-9a-fA-F]{32}', row['Build Key']) or not re.fullmatch(r'\d+(?:\.\d+){2,3}', row['Version']):
        raise ValueError('Malformed build identity')
    # These records identify an installation, not an entitlement or codec capability.
    identity = {'build_key': row['Build Key'].lower(), 'version': row['Version']}
    fingerprint = hashlib.sha256(json.dumps(identity, sort_keys=True, separators=(',', ':')).encode()).hexdigest()
    return {**identity, 'fingerprint': fingerprint, 'root': str(root),
            'installation_detected': True, 'presentation_supported': False,
            'reason': 'HD model, material and animation adapters are not implemented'}


def candidates():
    if os.environ.get('RTT_D2R_PATH'):
        yield Path(os.environ['RTT_D2R_PATH'])
    for variable in ('ProgramFiles(x86)', 'ProgramFiles'):
        if os.environ.get(variable):
            yield Path(os.environ[variable]) / 'Diablo II Resurrected'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--path', type=Path, help='Explicit local installation root')
    args = parser.parse_args()
    errors = []
    for root in [args.path] if args.path else candidates():
        try:
            print(json.dumps(inspect_install(root), indent=2))
            return 0
        except (OSError, UnicodeError, ValueError, csv.Error) as exc:
            errors.append(f'{root}: {exc}')
    print(json.dumps({'installation_detected': False, 'errors': errors or ['No installation candidates']}))
    return 1


if __name__ == '__main__':
    raise SystemExit(main())
