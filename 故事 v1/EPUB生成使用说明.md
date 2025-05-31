# EPUB生成与封面修复使用说明

## 📚 项目概述

本项目提供了完整的EPUB电子书生成解决方案，专门解决微信读书不显示封面的问题。包含两个核心工具：

1. **增强版EPUB生成器** (`build-epub-enhanced.sh`) - 直接生成优化的EPUB文件
2. **封面修复工具** (`fix-epub-cover.py`) - 修复现有EPUB文件的封面问题

## 🔧 环境准备

### 必需软件
```bash
# 安装pandoc
brew install pandoc  # macOS
# 或
sudo apt-get install pandoc  # Ubuntu/Debian

# 安装Python依赖
pip3 install lxml
```

### 必需文件
确保以下文件存在于工作目录：
- `metadata.yaml` - 书籍元数据
- `cover.jpg` - 封面图片
- `*.md` - 故事文件
- 样式文件（可选）

## 🚀 快速开始

### 方法一：使用增强版生成器（推荐）

```bash
# 进入故事目录
cd "故事 v1"

# 给脚本执行权限
chmod +x build-epub-enhanced.sh

# 运行增强版生成器
./build-epub-enhanced.sh
```

这将生成多个版本：
- `AI故事集-微信读书完美版.epub` - 微信读书专用优化版
- `AI故事集-GitHub风格.epub` - 电脑阅读版
- `AI故事集-Tufte学术风格.epub` - 学术阅读版

### 方法二：修复现有EPUB文件

```bash
# 修复现有的EPUB文件
python3 fix-epub-cover.py "原文件.epub" -o "修复后文件.epub"

# 或者直接修复（会生成 .fixed.epub 文件）
python3 fix-epub-cover.py "原文件.epub"
```

## 📱 微信读书封面问题解决方案

### 问题原因分析

微信读书不显示封面的主要原因：

1. **封面元数据不完整**
   ```xml
   <!-- Pandoc默认生成（问题） -->
   <item id="cover-image" href="cover.jpg" media-type="image/jpeg"/>
   
   <!-- 微信读书需要（正确） -->
   <item id="cover-image" href="cover.jpg" media-type="image/jpeg" properties="cover-image"/>
   <meta name="cover" content="cover-image"/>
   ```

2. **封面页面结构不标准**
   - 缺少专门的封面页面
   - SVG封面格式更兼容

3. **EPUB结构不完整**
   - spine中缺少封面页面引用
   - manifest中缺少必要属性

### 解决方案特点

我们的解决方案包含以下优化：

1. **标准化封面元数据**
   - 添加 `properties="cover-image"` 属性
   - 添加 `<meta name="cover" content="cover-image"/>` 元数据

2. **创建标准封面页面**
   ```html
   <svg xmlns="http://www.w3.org/2000/svg" 
        xmlns:xlink="http://www.w3.org/1999/xlink"
        height="100%" 
        preserveAspectRatio="xMidYMid meet" 
        version="1.1" 
        viewBox="0 0 600 800" 
        width="100%">
       <image height="800" width="600" xlink:href="cover.jpg"/>
   </svg>
   ```

3. **优化EPUB结构**
   - 封面页面添加到spine开头
   - 正确的mimetype文件处理
   - 标准的文件压缩方式

## 🎨 样式定制

### 微信读书优化样式特点

```css
/* 中文字体优化 */
font-family: "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", sans-serif;

/* 移动端适配 */
@media screen and (max-width: 768px) {
    body { font-size: 14px; }
    p { text-indent: 1.5em; }
}

/* 封面样式 */
.cover {
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
}
```

### 自定义样式

可以修改 `wechat-optimized.css` 来自定义样式：

1. **字体设置** - 修改 `font-family`
2. **颜色主题** - 修改标题和强调色
3. **排版参数** - 调整行距、段距、缩进
4. **移动端适配** - 优化小屏幕显示

## 🔍 故障排除

### 常见问题

1. **"未找到lxml库"**
   ```bash
   pip3 install lxml
   ```

2. **"未找到pandoc"**
   ```bash
   # macOS
   brew install pandoc
   
   # Ubuntu/Debian
   sudo apt-get install pandoc
   ```

3. **"权限被拒绝"**
   ```bash
   chmod +x build-epub-enhanced.sh
   ```

4. **封面仍然不显示**
   - 检查cover.jpg文件是否存在
   - 确保图片格式正确（JPG/PNG）
   - 尝试使用修复工具再次处理

### 调试模式

修复工具提供详细的调试信息：

```bash
python3 fix-epub-cover.py "文件.epub" -o "输出.epub"
```

输出示例：
```
🚀 开始修复EPUB封面...
📂 解压EPUB文件: 文件.epub
✅ 解压完成到: /tmp/tmpxxx
🔧 修复OPF文件: /tmp/tmpxxx/OEBPS/content.opf
✅ 设置封面图片属性: cover.jpg
✅ 添加封面元数据: cover-image
📄 创建标准封面页面
✅ 创建封面页面: /tmp/tmpxxx/OEBPS/cover.xhtml
📚 更新spine和manifest
✅ 添加封面页面到manifest
✅ 添加封面页面到spine开头
📦 重新打包EPUB: 输出.epub
✅ EPUB重新打包完成: 输出.epub
🎉 封面修复完成！
```

## 📋 文件结构

```
故事 v1/
├── build-epub-enhanced.sh      # 增强版生成器
├── fix-epub-cover.py          # 封面修复工具
├── metadata.yaml              # 书籍元数据
├── cover.jpg                  # 封面图片
├── modest-style.css           # 基础样式
├── more-styles/               # 其他样式
│   ├── github-style.css
│   ├── tufte-style.css
│   └── ...
├── *.md                       # 故事文件
└── *.epub                     # 生成的电子书
```

## 🎯 最佳实践

### 1. 封面图片要求
- **格式**: JPG或PNG
- **尺寸**: 建议600x800像素
- **大小**: 不超过2MB
- **质量**: 高清晰度，适合移动设备显示

### 2. 元数据优化
```yaml
title: "书名"
subtitle: "副标题"
author: "作者"
language: zh-CN              # 中文内容必须设置
cover-image: cover.jpg       # 封面文件名
identifier: "unique-id"      # 唯一标识符
```

### 3. 内容组织
- 使用标准的Markdown格式
- 合理使用标题层级（H1-H3）
- 适当的段落分隔
- 避免过长的单个文件

### 4. 测试流程
1. 生成EPUB文件
2. 在多个阅读器中测试
3. 特别测试微信读书的封面显示
4. 检查目录结构和导航

## 📞 技术支持

如果遇到问题，请检查：

1. **文件完整性** - 确保所有必需文件存在
2. **权限设置** - 确保脚本有执行权限
3. **依赖安装** - 确保pandoc和lxml已安装
4. **文件格式** - 确保Markdown文件格式正确

## 🔄 版本更新

### v2.0 新特性
- ✅ 完美解决微信读书封面显示问题
- ✅ 支持多种阅读器优化
- ✅ 自动化封面修复流程
- ✅ 详细的调试信息输出
- ✅ 中文字体和排版优化

### 未来计划
- 📱 支持更多移动阅读器
- 🎨 更多预设样式主题
- 🔧 图形化配置界面
- 📊 批量处理功能

---

*AI100Stories项目组 - 让AI知识触手可及* 🚀 