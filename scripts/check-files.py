#!/usr/bin/env python3
"""Check source invariants and local documentation links; no build output needed."""
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlsplit, unquote
import xml.etree.ElementTree as ET
root=Path(__file__).resolve().parent.parent
for path in (root/'recipe').rglob('*.xml'): ET.parse(path)
config=(root/'recipe/auto/config').read_text()
assert '--uefi-secure-boot enable' in config
assert 'nopersistence' in config
packages=(root/'recipe/config/package-lists/desktop.list.chroot').read_text().splitlines()
assert all(x in packages for x in ('labwc','firefox-esr','fcitx5-mozc','fonts-noto-cjk'))
assert len([x for x in packages if x and not x.startswith('#')])==len(set(x for x in packages if x and not x.startswith('#')))
class Page(HTMLParser):
    def __init__(self): super().__init__(); self.links=[]; self.ids=set()
    def handle_starttag(self,tag,attrs):
        attrs=dict(attrs)
        if 'id' in attrs:
            assert attrs['id'] not in self.ids
            self.ids.add(attrs['id'])
        if tag=='a' and 'href' in attrs: self.links.append(attrs['href'])
        if tag in ('link','script','img'):
            asset=attrs.get('href',attrs.get('src',''))
            if asset: self.links.append(asset)
pages={}
for file in (root/'docs').glob('*.html'):
    page=Page();page.feed(file.read_text());pages[file]=page
for file,page in pages.items():
    for link in page.links:
        url=urlsplit(link)
        if url.scheme or url.netloc: continue
        target=(file.parent/unquote(url.path)).resolve() if url.path else file
        assert target.is_relative_to(root.resolve()) and target.exists(), (file,link)
        if url.fragment and target in pages: assert url.fragment in pages[target].ids,(file,link)
assert (root/'docs/index.html').exists()
print('XML, package list, Secure Boot/RAM policy and documentation links: PASS')
