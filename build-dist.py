from pathlib import Path
import json
import shutil

root = Path(__file__).resolve().parent
public_files = ['index.html']
ui_files = ['index.html', 'app.js', 'styles.css', 'markdown.js']
platforms = ['wechat', 'android', 'ios']
routes = [
    'home', 'records', 'inr', 'me', 'login',
    'inr-settings', 'inr-methods', 'test-settings',
    'dose-settings', 'after-dose-rule',
    'notifications', 'account', 'profile', 'help',
]
legacy_route_dirs = [f'{platform}/{route}' for platform in platforms for route in routes]
ui_route_dirs = [f'ui/{platform}/{route}' for platform in platforms for route in routes]
route_dirs = legacy_route_dirs + ui_route_dirs
markdown_docs = [
    'README.md',
    'docs/ui/README.md',
    'docs/product/module-feature-inventory.md',
    'docs/product/current-progress.md',
    'docs/tech/technical-proposal.md',
    'docs/tech/architecture-report.md',
    'docs/tech/database-and-cache-design.md',
    'docs/tech/base-data-and-schema-review.md',
    'docs/plans/2026-04-24-multiplatform-mvp.md',
    'docs/reports/2026-04-25-inr-refinement-implementation.md',
    'docs/reports/2026-04-25-server-copy-contract.md',
    'docs/reports/2026-04-27-project-boundary-independent-run.md',
    'docs/reports/2026-04-27-flutter-sdk-verification.md',
    'docs/reports/2026-04-27-project-structure-ui-docs-landing.md',
]

docs_landing = '''<!doctype html>
<html lang="zh-CN">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>抗凝小助手 · Docs 文档</title>
    <link rel="stylesheet" href="/ui/styles.css" />
  </head>
  <body>
    <main class="landing portalLanding docsLanding">
      <section class="hero portalHero">
        <div>
          <p class="eyebrow">Documentation Portal</p>
          <h1>抗凝小助手 Docs 文档中心</h1>
          <p class="lead">按产品、UI、技术方案、计划和交付报告组织所有 Markdown 文档；每篇文档都支持 Cloudflare 在线美化预览与 raw Markdown 访问。</p>
        </div>
        <a class="chip" href="/">返回统一入口</a>
      </section>
      <section class="portalGrid docsIndexGrid">
        {cards}
      </section>
    </main>
  </body>
</html>'''


landing_index = (root / 'index.html').read_text(encoding='utf-8')
ui_index = (root / 'ui' / 'index.html').read_text(encoding='utf-8')
markdown_index = ui_index.replace('/ui/styles.css', '/ui/styles.css').replace('/ui/app.js', '/ui/app.js').replace('/ui/markdown.js', '/ui/markdown.js')
dist = root / 'dist'
if dist.exists():
    shutil.rmtree(dist)
dist.mkdir()

for name in public_files:
    src = root / name
    if src.exists():
        shutil.copy2(src, dist / name)

ui_dist = dist / 'ui'
ui_dist.mkdir(parents=True, exist_ok=True)
for name in ui_files:
    src = root / 'ui' / name
    if src.exists():
        shutil.copy2(src, ui_dist / name)

docs_index = dist / 'docs'
docs_index.mkdir(parents=True, exist_ok=True)

for route in route_dirs:
    target = dist / route
    target.mkdir(parents=True, exist_ok=True)
    shutil.copy2(root / 'ui' / 'index.html', target / 'index.html')

def preview_route_for(md_path: str) -> str:
    without_ext = md_path[:-3]
    return without_ext

def make_preview_html(markdown: str) -> str:
    source = json.dumps(markdown, ensure_ascii=False)
    return markdown_index.replace('<script src="/ui/markdown.js"></script>', f'<script id="md-source" type="application/json">{source}</script>\n    <script src="/ui/markdown.js"></script>')

doc_cards = []
for name in markdown_docs:
    src = root / name
    if not src.exists():
        continue
    title = name[:-3].split('/')[-1].replace('-', ' ')
    route = preview_route_for(name)
    doc_cards.append(f'<article class="portalCard"><p class="eyebrow">{name}</p><h2>{title}</h2><p>查看在线预览，必要时可通过 ?raw=1 读取原始 Markdown。</p><div class="portalActions"><a class="primaryLink" href="/{route}/">打开文档 <span>›</span></a><a href="/{name}?raw=1">Raw Markdown</a></div></article>')
    raw_dst = dist / name
    raw_dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, raw_dst)

    route = preview_route_for(name)
    preview_dir = dist / route
    preview_dir.mkdir(parents=True, exist_ok=True)
    preview_html = make_preview_html(src.read_text(encoding='utf-8'))
    (preview_dir / 'index.html').write_text(preview_html, encoding='utf-8')

(docs_index / 'index.html').write_text(docs_landing.format(cards='\n'.join(doc_cards)), encoding='utf-8')

print(f'built {dist}')
