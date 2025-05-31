#!/bin/bash
# build-epub.sh
# AI故事集电子书生成器
# 生成最佳阅读体验的EPUB文件
# 作者：AI100Stories项目组

echo "🚀 AI故事集电子书生成器启动..."
echo "📚 生成最佳阅读体验版本"

# 检查必要文件
if [ ! -f "metadata.yaml" ]; then
    echo "❌ 未找到 metadata.yaml 文件"
    exit 1
fi

if [ ! -f "modest-style.css" ]; then
    echo "❌ 未找到 modest-style.css 文件"
    exit 1
fi

# 检查封面文件
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

# 从metadata.yaml中提取书名
BOOK_TITLE=$(python3 -c "
import yaml
with open('metadata.yaml', 'r', encoding='utf-8') as f:
    data = yaml.safe_load(f)
    title = data.get('title', 'AI故事集')
    print(title)
" 2>/dev/null || echo "读故事学AI")

echo "📖 书名: $BOOK_TITLE"

# 生成参数
PANDOC_PARAMS="--toc --toc-depth=2 --split-level=1"

# 生成EPUB
echo "📚 正在生成电子书..."
pandoc metadata.yaml *.md $PANDOC_PARAMS \
    --css=modest-style.css \
    $COVER_OPTION \
    --epub-metadata=metadata.yaml \
    -o "${BOOK_TITLE}.epub"

if [ $? -eq 0 ]; then
    echo "✅ 基础版本生成成功: ${BOOK_TITLE}.epub"
    
    # 使用修复脚本优化封面
    if [ -f "fix-epub-cover.py" ]; then
        echo "🔧 优化封面显示..."
        python3 fix-epub-cover.py "${BOOK_TITLE}.epub" -o "${BOOK_TITLE}-完美版.epub"
        
        if [ $? -eq 0 ]; then
            echo "✅ 封面优化完成"
            echo "📱 推荐使用: ${BOOK_TITLE}-完美版.epub"
            
            # 删除基础版本，只保留完美版
            rm -f "${BOOK_TITLE}.epub"
            mv "${BOOK_TITLE}-完美版.epub" "${BOOK_TITLE}.epub"
            echo "🎯 最终版本: ${BOOK_TITLE}.epub"
        else
            echo "⚠️  封面优化失败，使用基础版本"
        fi
    else
        echo "⚠️  未找到修复脚本，跳过封面优化"
    fi
else
    echo "❌ EPUB生成失败"
    exit 1
fi

echo ""
echo "🎉 电子书生成完成！"
echo "📁 生成的文件:"
ls -la "${BOOK_TITLE}.epub"
echo ""
echo "📱 适用于所有主流阅读器，包括微信读书"
echo "🎯 享受阅读吧！" 