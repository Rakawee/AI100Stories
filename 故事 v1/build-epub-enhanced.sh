#!/bin/bash
# build-epub-enhanced.sh
# AI故事集电子书增强生成器
# 专门解决微信读书封面显示问题
# 作者：AI100Stories项目组

echo "🚀 AI故事集电子书增强生成器启动..."
echo "📱 专门优化微信读书封面显示"

# 检查必要文件
if [ ! -f "metadata.yaml" ]; then
    echo "❌ 未找到 metadata.yaml 文件"
    exit 1
fi

if [ ! -f "cover.jpg" ]; then
    echo "⚠️  未找到 cover.jpg，将跳过封面"
    COVER_OPTION=""
else
    COVER_OPTION="--epub-cover-image=cover.jpg"
    echo "✅ 找到封面文件: cover.jpg"
fi

# 检查Python依赖
if ! python3 -c "import lxml" 2>/dev/null; then
    echo "⚠️  未安装lxml库，正在安装..."
    pip3 install lxml
fi

# 创建增强的元数据文件
echo "📝 创建增强元数据文件..."
cat > enhanced-metadata.yaml << 'EOF'
---
title: "读故事学AI"
subtitle: "100个故事破解技术黑话"
author: "公众号：向阳乔木推荐看；X：vista8"
date: "2024-12-19"
language: zh-CN
publisher: "AI领导力学院"
rights: "© 2024 AI领导力学院 版权所有"
description: |
  AI领导力学院精心打造的AI科普读物。通过100个引人入胜的故事，
  将晦涩难懂的人工智能技术转化为生动易懂的叙事。无论你是AI初学者
  还是技术爱好者，都能在这些故事中找到属于自己的AI启蒙之路。
subject: "人工智能, 科普教育, 技术故事, AI领导力"
cover-image: cover.jpg
identifier: "AILA-AI-Stories-2024"
---
EOF

# 创建微信读书优化的CSS
echo "🎨 创建微信读书优化样式..."
cat > wechat-optimized.css << 'EOF'
/* 微信读书优化样式 */
@charset "UTF-8";

/* 基础设置 */
html {
    font-size: 16px;
    line-height: 1.6;
}

body {
    font-family: "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", "WenQuanYi Micro Hei", sans-serif;
    color: #333;
    margin: 0;
    padding: 1em;
    background: #fff;
}

/* 标题样式 */
h1, h2, h3, h4, h5, h6 {
    font-weight: bold;
    margin: 1.5em 0 0.5em 0;
    line-height: 1.4;
    color: #2c3e50;
}

h1 {
    font-size: 2.2em;
    text-align: center;
    border-bottom: 3px solid #3498db;
    padding-bottom: 0.3em;
    margin-bottom: 1em;
}

h2 {
    font-size: 1.8em;
    color: #34495e;
}

h3 {
    font-size: 1.5em;
    color: #7f8c8d;
}

/* 段落样式 */
p {
    margin: 1em 0;
    text-indent: 2em;
    text-align: justify;
}

/* 强调样式 */
strong, b {
    font-weight: bold;
    color: #e74c3c;
}

em, i {
    font-style: italic;
    color: #9b59b6;
}

/* 引用样式 */
blockquote {
    margin: 1.5em 0;
    padding: 1em;
    background: #f8f9fa;
    border-left: 4px solid #3498db;
    font-style: italic;
}

/* 代码样式 */
code {
    font-family: "SF Mono", Monaco, "Cascadia Code", "Roboto Mono", Consolas, "Courier New", monospace;
    background: #f1f2f6;
    padding: 0.2em 0.4em;
    border-radius: 3px;
    font-size: 0.9em;
}

pre {
    background: #2f3640;
    color: #f5f6fa;
    padding: 1em;
    border-radius: 5px;
    overflow-x: auto;
    margin: 1.5em 0;
}

pre code {
    background: none;
    padding: 0;
    color: inherit;
}

/* 列表样式 */
ul, ol {
    margin: 1em 0;
    padding-left: 2em;
}

li {
    margin: 0.5em 0;
}

/* 链接样式 */
a {
    color: #3498db;
    text-decoration: none;
}

a:hover {
    color: #2980b9;
    text-decoration: underline;
}

/* 图片样式 */
img {
    max-width: 100%;
    height: auto;
    display: block;
    margin: 1em auto;
    border-radius: 5px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

/* 表格样式 */
table {
    width: 100%;
    border-collapse: collapse;
    margin: 1.5em 0;
}

th, td {
    border: 1px solid #ddd;
    padding: 0.8em;
    text-align: left;
}

th {
    background: #f8f9fa;
    font-weight: bold;
}

/* 分页设置 */
@media print {
    h1, h2, h3 {
        page-break-after: avoid;
    }
    
    p, blockquote {
        page-break-inside: avoid;
    }
}

/* 封面特殊样式 */
.cover {
    text-align: center;
    height: 100vh;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
}

.cover img {
    max-width: 90%;
    max-height: 80%;
    object-fit: contain;
    box-shadow: 0 4px 20px rgba(0,0,0,0.3);
}

/* 目录样式 */
#TOC {
    background: #f8f9fa;
    border: 1px solid #dee2e6;
    border-radius: 5px;
    padding: 1.5em;
    margin: 2em 0;
}

#TOC ul {
    list-style: none;
    padding-left: 0;
}

#TOC li {
    margin: 0.3em 0;
}

#TOC a {
    display: block;
    padding: 0.3em 0;
    border-bottom: 1px dotted #ccc;
}

/* 章节分隔 */
.chapter {
    page-break-before: always;
    margin-top: 2em;
}

/* 微信读书特殊优化 */
@media screen and (max-width: 768px) {
    body {
        padding: 0.5em;
        font-size: 14px;
    }
    
    h1 {
        font-size: 1.8em;
    }
    
    h2 {
        font-size: 1.5em;
    }
    
    p {
        text-indent: 1.5em;
    }
}
EOF

# 基础参数
BASE_PARAMS="--toc --toc-depth=2 --split-level=1 --epub-chapter-level=1"

# 生成标准版本
echo "📚 生成微信读书优化版本..."
pandoc enhanced-metadata.yaml *.md $BASE_PARAMS \
    --css=wechat-optimized.css \
    $COVER_OPTION \
    --epub-metadata=enhanced-metadata.yaml \
    -o "AI故事集-微信读书优化版.epub"

if [ $? -eq 0 ]; then
    echo "✅ 基础版本生成成功"
    
    # 检查是否有修复脚本
    if [ -f "fix-epub-cover.py" ]; then
        echo "🔧 使用修复脚本优化封面..."
        python3 fix-epub-cover.py "AI故事集-微信读书优化版.epub" -o "AI故事集-微信读书完美版.epub"
        
        if [ $? -eq 0 ]; then
            echo "✅ 封面修复完成"
            echo "📱 推荐使用: AI故事集-微信读书完美版.epub"
        else
            echo "⚠️  封面修复失败，使用基础版本"
        fi
    else
        echo "⚠️  未找到修复脚本，跳过封面优化"
    fi
else
    echo "❌ EPUB生成失败"
    exit 1
fi

# 生成其他风格版本
echo ""
echo "📚 生成其他风格版本..."

# GitHub风格
if [ -f "more-styles/github-style.css" ]; then
    echo "🐙 生成GitHub风格版本..."
    pandoc enhanced-metadata.yaml *.md $BASE_PARAMS \
        --css=more-styles/github-style.css \
        $COVER_OPTION \
        -o "AI故事集-GitHub风格.epub"
fi

# Tufte风格
if [ -f "more-styles/tufte-style.css" ]; then
    echo "📖 生成Tufte学术风格版本..."
    pandoc enhanced-metadata.yaml *.md $BASE_PARAMS \
        --css=more-styles/tufte-style.css \
        $COVER_OPTION \
        -o "AI故事集-Tufte学术风格.epub"
fi

# 清理临时文件
rm -f enhanced-metadata.yaml

echo ""
echo "🎉 所有版本生成完成！"
echo "📁 生成的文件："
ls -la *.epub | grep -E "(微信读书|GitHub|Tufte)" || ls -la *.epub
echo ""
echo "📱 微信读书推荐使用: AI故事集-微信读书完美版.epub"
echo "💻 电脑阅读推荐使用: AI故事集-GitHub风格.epub"
echo "📚 学术阅读推荐使用: AI故事集-Tufte学术风格.epub"
echo ""
echo "🎯 享受阅读吧！" 