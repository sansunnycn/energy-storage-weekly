#!/usr/bin/env bash
# 储能周报自动发布脚本：重建 index.html 历史索引并推送到 GitHub Pages
# 用法：bash publish.sh
set -e
R="$(cd "$(dirname "$0")" && pwd)"
cd "$R"

# 1) 收集所有 YYYY-MM-DD.html，倒序（最新在前）
mapfile -t FILES < <(ls -1 2>/dev/null | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}\.html$' | sort -r)
if [ ${#FILES[@]} -eq 0 ]; then
  echo "!! 未找到 YYYY-MM-DD.html 周报文件，跳过 index 重建"
fi

# 2) 生成列表 HTML
LIST=""
FIRST=1
for f in "${FILES[@]}"; do
  d="${f%.html}"
  tag=""
  if [ "$FIRST" = "1" ]; then tag=' <span class="badge">本期</span>'; FIRST=0; fi
  LIST+="  <div class=\"card\"><span class=\"date\">${d}</span><a href=\"${f}\">储能行业市场周报（全国+广东）</a>${tag}</div>\n"
done

cat > index.html <<INDEXEOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>储能行业市场周报 · 历史归档</title>
<style>
  body{font-family:"Microsoft YaHei","PingFang SC",sans-serif;background:#f7faf9;color:#222;margin:0;line-height:1.7;}
  .wrap{max-width:900px;margin:0 auto;padding:30px 22px;}
  header{background:linear-gradient(135deg,#0b3d2e,#0a7d5c);color:#fff;padding:22px 0;margin-bottom:10px;}
  .wrap-in{max-width:900px;margin:0 auto;padding:0 22px;}
  h1{margin:0 0 6px;font-size:24px;}
  .sub{opacity:.92;font-size:13px;}
  .card{background:#fff;border:1px solid #d8e6e0;border-left:4px solid #0a7d5c;border-radius:6px;padding:14px 18px;margin:12px 0;}
  a{color:#0a7d5c;text-decoration:none;font-size:17px;font-weight:bold;}
  a:hover{text-decoration:underline;}
  .date{color:#888;font-size:13px;margin-right:8px;}
  .badge{display:inline-block;background:#0a7d5c;color:#fff;border-radius:4px;padding:0 7px;font-size:12px;}
  .note{color:#777;font-size:13px;}
</style>
</head>
<body>
<header><div class="wrap-in">
  <h1>储能行业市场周报</h1>
  <div class="sub">中国 · 重点独立储能/电网侧 · 广东区域专项｜每周更新，历史可查</div>
</div></header>
<div class="wrap">
  <div class="card note">本页为归档首页：每周一自动生成新一期并追加至下方列表，点击可查看任意历史周报。内容由公开信息检索整理，标注【待核】项发布/上报前请以官方原文复核，不构成投资建议。</div>
  <h2 style="color:#0b3d2e;">往期周报</h2>
$(echo -e "$LIST")
  <div class="card note" style="margin-top:24px;">发布方式：sansunnycn/energy-storage-weekly · GitHub Pages 自动生成</div>
</div>
</body>
</html>
INDEXEOF

echo "已重建 index.html，收录 ${#FILES[@]} 期"

# 3) 提交并推送
if git add -A && git diff --cached --quiet; then
  echo "无新改动，无需提交"
else
  git commit -m "weekly update: $(date +%F)" >/dev/null 2>&1
  echo "已提交"
fi
git push origin main
echo "✅ 已推送 → https://sansunnycn.github.io/energy-storage-weekly/"
