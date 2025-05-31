# EPUB生成使用说明

## 📚 项目概述

本项目提供了简洁高效的EPUB电子书生成解决方案，**完美解决微信读书封面显示问题**，生成最佳阅读体验的电子书。

## 🔧 环境准备

### 必需软件
```bash
# 安装pandoc
brew install pandoc  # macOS
# 或
sudo apt-get install pandoc  # Ubuntu/Debian

# 安装Python依赖
pip3 install lxml PyYAML
```

### 必需文件
确保以下文件存在于工作目录：
- `metadata.yaml` - 书籍元数据
- `cover.jpg` - 封面图片
- `modest-style.css` - 样式文件
- `*.md` - 故事文件

## 🚀 快速开始

### 一键生成最佳版本

```bash
# 进入故事目录
cd "故事 v1"

# 给脚本执行权限（首次使用）
chmod +x build-epub.sh

# 生成电子书
./build-epub.sh
```

这将生成一个完美优化的EPUB文件，文件名使用metadata.yaml中的书名。

### 修复现有EPUB文件

如果您有其他EPUB文件需要修复封面问题：

```bash
python3 fix-epub-cover.py "原文件.epub" -o "修复版.epub"
```

## 📱 微信读书封面问题解决方案

### 问题原因
微信读书不显示封面的主要原因：
1. **封面元数据不完整** - 缺少`properties="cover-image"`属性
2. **封面页面结构不标准** - 缺少专门的封面页面
3. **EPUB结构不完整** - spine和manifest配置不正确

### 我们的解决方案
✅ **标准化封面元数据** - 自动添加所有必需属性  
✅ **创建SVG封面页面** - 使用标准格式确保兼容性  
✅ **优化EPUB结构** - 正确的文件组织和压缩  
✅ **自动封面查找** - 智能查找和复制封面图片  

## 🎨 样式特点

使用经过优化的modest样式，具有以下特点：
- 📱 **移动端友好** - 适配各种屏幕尺寸
- 🇨🇳 **中文优化** - 专门优化的中文字体和排版
- 👁️ **护眼设计** - 舒适的颜色搭配和行距
- 🎯 **专业排版** - 清晰的层次结构和视觉效果

## 🔍 故障排除

### 常见问题

1. **"未找到lxml库"**
   ```bash
   pip3 install lxml
   ```

2. **"未找到PyYAML库"**
   ```bash
   pip3 install PyYAML
   ```

3. **"未找到pandoc"**
   ```bash
   # macOS
   brew install pandoc
   
   # Ubuntu/Debian
   sudo apt-get install pandoc
   ```

4. **"权限被拒绝"**
   ```bash
   chmod +x build-epub.sh
   ```

### 生成过程说明

脚本会自动执行以下步骤：
1. 📋 检查必需文件和依赖
2. 📖 从metadata.yaml提取书名
3. 📚 使用pandoc生成基础EPUB
4. 🔧 自动优化封面显示
5. 🎯 生成最终完美版本

## 📋 文件结构

```
故事 v1/
├── build-epub.sh              # EPUB生成器
├── fix-epub-cover.py          # 封面修复工具
├── metadata.yaml              # 书籍元数据
├── cover.jpg                  # 封面图片
├── modest-style.css           # 样式文件
├── *.md                       # 故事文件
└── 读故事学AI.epub            # 生成的电子书
```

## 🎯 最佳实践

### 封面图片要求
- **格式**: JPG或PNG
- **尺寸**: 建议600x800像素
- **大小**: 不超过2MB
- **质量**: 高清晰度，适合移动设备显示

### 元数据配置
```yaml
title: "书名"                  # 将用作文件名
subtitle: "副标题"
author: "作者"
language: zh-CN               # 中文内容必须设置
cover-image: cover.jpg        # 封面文件名
```

### 内容组织
- 使用标准的Markdown格式
- 合理使用标题层级（H1-H3）
- 适当的段落分隔
- 避免过长的单个文件

## 📱 兼容性

生成的EPUB文件完美支持：
- ✅ **微信读书** - 封面完美显示
- ✅ **Apple Books** - 优秀的阅读体验
- ✅ **Kindle** - 良好的兼容性
- ✅ **其他阅读器** - 广泛兼容

## 🔄 版本信息

### v3.0 新特性
- ✅ 简化为单一最佳版本生成
- ✅ 自动使用元数据中的书名命名
- ✅ 完美的微信读书封面显示
- ✅ 优化的modest样式
- ✅ 一键生成，无需选择

---

*AI100Stories项目组 - 让AI知识触手可及* 🚀 