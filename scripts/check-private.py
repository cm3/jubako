#!/usr/bin/env python3
"""Heuristic check of the INDEX, not ignored local outputs. Never prints secret values."""
from pathlib import Path
import re,subprocess
root=Path(__file__).resolve().parent.parent
files=subprocess.check_output(['git','-C',str(root),'ls-files','--cached','-z']).decode().split('\0')
patterns=[
 re.compile(rb'-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----'),
 re.compile(rb'gh[pousr]_[A-Za-z0-9]{20,}'),
 re.compile(rb'sk-[A-Za-z0-9_-]{20,}'),
 re.compile(rb'/home/[^/\s]+/projects/'),
 re.compile(rb'C:\\Users\\[^\\\s]+'),
]
errors=[]
for name in filter(None,files):
 if name.startswith(('build/','.git/','tmp/')) or name.endswith(('.iso','.img','.deb','.pem','.key','.log')):
  errors.append((name,'generated/private file in index'));continue
 data=subprocess.check_output(['git','-C',str(root),'show',':'+name])
 if b'\0' in data: errors.append((name,'unexpected binary'));continue
 if name!='scripts/check-private.py' and any(p.search(data) for p in patterns):
  errors.append((name,'secret or personal-path pattern'))
for name,reason in errors:print(f'FAIL: {name}: {reason}')
if errors:raise SystemExit(1)
print(f'Index privacy check: PASS ({len(list(filter(None,files)))} text/source files).')
print('Pattern scan is not proof: review git diff --cached before publishing.')
