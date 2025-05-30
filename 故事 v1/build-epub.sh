#!/bin/bash
# build-epub.sh
# AI故事集电子书多风格生成器
# 作者：StoryWeaver
# 用途：一键生成 GitHub、Tufte、Modest 三种风格的 epub 电子书

echo "🚀 AI故事集电子书生成器启动..."

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
fi

# 基础参数

echo "🚀 AI故事集电子书生成器（扩展版）启动..."

BASE_PARAMS="--toc --toc-depth=2 --split-level=1"
COVER_OPTION="--epub-cover-image=cover.jpg"

echo "📚 生成 Modest 简洁风格版本..."
pandoc metadata.yaml *.md $BASE_PARAMS --css=modest-style.css $COVER_OPTION -o "AI故事集-Modest风格.epub"

echo "✅ 所有版本生成完成！"
echo "📁 生成的文件："
ls -la *.epub
echo ""
echo "🎉 享受阅读吧！"
