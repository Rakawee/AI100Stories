#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EPUB封面修复工具
专门解决微信读书不显示封面的问题

作者：AI100Stories项目组
用途：修复pandoc生成的epub文件，使其在微信读书中正确显示封面
"""

import zipfile
import os
import shutil
import tempfile
from pathlib import Path
from lxml import etree, html
import argparse

class EPUBCoverFixer:
    def __init__(self, epub_path):
        self.epub_path = Path(epub_path)
        self.temp_dir = None
        
    def __enter__(self):
        self.temp_dir = tempfile.mkdtemp()
        return self
        
    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.temp_dir and os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir)
    
    def extract_epub(self):
        """解压EPUB文件到临时目录"""
        print(f"📂 解压EPUB文件: {self.epub_path}")
        with zipfile.ZipFile(self.epub_path, 'r') as zip_ref:
            zip_ref.extractall(self.temp_dir)
        print(f"✅ 解压完成到: {self.temp_dir}")
    
    def find_opf_file(self):
        """查找content.opf文件"""
        for root, dirs, files in os.walk(self.temp_dir):
            for file in files:
                if file.endswith('.opf'):
                    return os.path.join(root, file)
        raise FileNotFoundError("未找到.opf文件")
    
    def find_cover_image(self, opf_dir):
        """查找封面图片文件"""
        # 首先在当前目录查找
        for ext in ['jpg', 'jpeg', 'png', 'JPG', 'JPEG', 'PNG']:
            for name in ['cover', 'Cover', 'COVER']:
                potential_cover = os.path.join(opf_dir, f'{name}.{ext}')
                if os.path.exists(potential_cover):
                    return f'{name}.{ext}'
        
        # 在父目录查找
        parent_dir = os.path.dirname(opf_dir)
        for ext in ['jpg', 'jpeg', 'png', 'JPG', 'JPEG', 'PNG']:
            for name in ['cover', 'Cover', 'COVER']:
                potential_cover = os.path.join(parent_dir, f'{name}.{ext}')
                if os.path.exists(potential_cover):
                    # 复制到opf目录
                    target_path = os.path.join(opf_dir, f'cover.{ext.lower()}')
                    shutil.copy2(potential_cover, target_path)
                    return f'cover.{ext.lower()}'
        
        # 查找项目根目录的封面
        project_cover = os.path.join(os.path.dirname(self.epub_path), 'cover.jpg')
        if os.path.exists(project_cover):
            target_path = os.path.join(opf_dir, 'cover.jpg')
            shutil.copy2(project_cover, target_path)
            print(f"✅ 从项目目录复制封面: {project_cover}")
            return 'cover.jpg'
        
        return None
    
    def fix_opf_metadata(self, opf_path):
        """修复OPF文件中的封面元数据"""
        print(f"🔧 修复OPF文件: {opf_path}")
        
        # 解析OPF文件
        parser = etree.XMLParser(remove_blank_text=True)
        tree = etree.parse(opf_path, parser)
        root = tree.getroot()
        
        # 定义命名空间
        namespaces = {
            'opf': 'http://www.idpf.org/2007/opf',
            'dc': 'http://purl.org/dc/elements/1.1/'
        }
        
        # 查找manifest元素
        manifest = root.find('.//opf:manifest', namespaces)
        if manifest is None:
            print("❌ 未找到manifest元素")
            return False
        
        opf_dir = os.path.dirname(opf_path)
        
        # 查找封面图片项
        cover_item = None
        cover_image_file = None
        
        # 首先尝试在manifest中查找现有的封面项
        for item in manifest.findall('.//opf:item', namespaces):
            href = item.get('href', '')
            if 'cover' in href.lower() and any(ext in href.lower() for ext in ['.jpg', '.jpeg', '.png']):
                cover_item = item
                cover_image_file = href
                break
        
        # 如果没有找到，尝试查找封面图片文件
        if cover_item is None:
            cover_image_file = self.find_cover_image(opf_dir)
            if cover_image_file:
                # 创建新的封面项
                cover_item = etree.SubElement(manifest, '{http://www.idpf.org/2007/opf}item')
                cover_item.set('id', 'cover-image')
                cover_item.set('href', cover_image_file)
                
                # 根据文件扩展名设置media-type
                ext = cover_image_file.lower().split('.')[-1]
                if ext in ['jpg', 'jpeg']:
                    cover_item.set('media-type', 'image/jpeg')
                elif ext == 'png':
                    cover_item.set('media-type', 'image/png')
                else:
                    cover_item.set('media-type', 'image/jpeg')  # 默认
                
                print(f"✅ 创建新的封面图片项: {cover_image_file}")
            else:
                print("❌ 未找到封面图片文件")
                return False
        
        # 修复封面图片项的属性
        cover_item.set('properties', 'cover-image')
        print(f"✅ 设置封面图片属性: {cover_item.get('href')}")
        
        # 查找metadata元素
        metadata = root.find('.//opf:metadata', namespaces)
        if metadata is None:
            print("❌ 未找到metadata元素")
            return False
        
        # 检查是否已有cover meta标签
        existing_cover_meta = metadata.find('.//opf:meta[@name="cover"]', namespaces)
        if existing_cover_meta is None:
            # 添加cover meta标签
            cover_meta = etree.SubElement(metadata, '{http://www.idpf.org/2007/opf}meta')
            cover_meta.set('name', 'cover')
            cover_meta.set('content', cover_item.get('id'))
            print(f"✅ 添加封面元数据: {cover_item.get('id')}")
        else:
            # 更新现有的cover meta标签
            existing_cover_meta.set('content', cover_item.get('id'))
            print(f"✅ 更新封面元数据: {cover_item.get('id')}")
        
        # 保存修改后的OPF文件
        tree.write(opf_path, encoding='utf-8', xml_declaration=True, pretty_print=True)
        return True, cover_image_file
    
    def create_cover_page(self, opf_dir, cover_image_file):
        """创建标准的封面页面"""
        print("📄 创建标准封面页面")
        
        if not cover_image_file:
            print("❌ 未指定封面图片文件")
            return False
        
        # 创建封面HTML页面
        cover_html = f'''<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>封面</title>
    <style type="text/css">
        body {{
            margin: 0;
            padding: 0;
            text-align: center;
        }}
        .cover {{
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }}
        .cover img {{
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }}
    </style>
</head>
<body>
    <div class="cover">
        <svg xmlns="http://www.w3.org/2000/svg" 
             xmlns:xlink="http://www.w3.org/1999/xlink"
             height="100%" 
             preserveAspectRatio="xMidYMid meet" 
             version="1.1" 
             viewBox="0 0 600 800" 
             width="100%">
            <image height="800" width="600" xlink:href="{cover_image_file}"/>
        </svg>
    </div>
</body>
</html>'''
        
        cover_path = os.path.join(opf_dir, 'cover.xhtml')
        with open(cover_path, 'w', encoding='utf-8') as f:
            f.write(cover_html)
        
        print(f"✅ 创建封面页面: {cover_path}")
        return True
    
    def update_spine_and_manifest(self, opf_path):
        """更新spine和manifest以包含封面页面"""
        print("📚 更新spine和manifest")
        
        parser = etree.XMLParser(remove_blank_text=True)
        tree = etree.parse(opf_path, parser)
        root = tree.getroot()
        
        namespaces = {
            'opf': 'http://www.idpf.org/2007/opf',
            'dc': 'http://purl.org/dc/elements/1.1/'
        }
        
        # 查找manifest
        manifest = root.find('.//opf:manifest', namespaces)
        
        # 检查是否已有封面页面项
        cover_page_item = manifest.find('.//opf:item[@id="cover-page"]', namespaces)
        if cover_page_item is None:
            # 添加封面页面到manifest
            cover_page_item = etree.SubElement(manifest, '{http://www.idpf.org/2007/opf}item')
            cover_page_item.set('id', 'cover-page')
            cover_page_item.set('href', 'cover.xhtml')
            cover_page_item.set('media-type', 'application/xhtml+xml')
            print("✅ 添加封面页面到manifest")
        
        # 查找spine
        spine = root.find('.//opf:spine', namespaces)
        if spine is not None:
            # 检查封面页面是否已在spine中
            cover_itemref = spine.find('.//opf:itemref[@idref="cover-page"]', namespaces)
            if cover_itemref is None:
                # 在spine开头添加封面页面
                cover_itemref = etree.Element('{http://www.idpf.org/2007/opf}itemref')
                cover_itemref.set('idref', 'cover-page')
                cover_itemref.set('linear', 'yes')
                spine.insert(0, cover_itemref)
                print("✅ 添加封面页面到spine开头")
        
        # 保存修改
        tree.write(opf_path, encoding='utf-8', xml_declaration=True, pretty_print=True)
        return True
    
    def repack_epub(self, output_path=None):
        """重新打包EPUB文件"""
        if output_path is None:
            output_path = self.epub_path.with_suffix('.fixed.epub')
        
        print(f"📦 重新打包EPUB: {output_path}")
        
        with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
            # 首先添加mimetype文件（必须是第一个且不压缩）
            mimetype_path = os.path.join(self.temp_dir, 'mimetype')
            if os.path.exists(mimetype_path):
                zipf.write(mimetype_path, 'mimetype', compress_type=zipfile.ZIP_STORED)
            
            # 添加其他所有文件
            for root, dirs, files in os.walk(self.temp_dir):
                for file in files:
                    if file == 'mimetype':
                        continue  # 已经添加过了
                    
                    file_path = os.path.join(root, file)
                    arc_path = os.path.relpath(file_path, self.temp_dir)
                    zipf.write(file_path, arc_path)
        
        print(f"✅ EPUB重新打包完成: {output_path}")
        return output_path
    
    def fix_cover(self, output_path=None):
        """执行完整的封面修复流程"""
        print("🚀 开始修复EPUB封面...")
        
        try:
            # 1. 解压EPUB
            self.extract_epub()
            
            # 2. 查找OPF文件
            opf_path = self.find_opf_file()
            opf_dir = os.path.dirname(opf_path)
            
            # 3. 修复OPF元数据
            result = self.fix_opf_metadata(opf_path)
            if isinstance(result, tuple):
                success, cover_image_file = result
                if not success:
                    print("❌ 修复OPF元数据失败")
                    return False
            else:
                print("❌ 修复OPF元数据失败")
                return False
            
            # 4. 创建标准封面页面
            if not self.create_cover_page(opf_dir, cover_image_file):
                print("❌ 创建封面页面失败")
                return False
            
            # 5. 更新spine和manifest
            if not self.update_spine_and_manifest(opf_path):
                print("❌ 更新spine和manifest失败")
                return False
            
            # 6. 重新打包
            fixed_path = self.repack_epub(output_path)
            
            print(f"🎉 封面修复完成！")
            print(f"📁 修复后的文件: {fixed_path}")
            return fixed_path
            
        except Exception as e:
            print(f"❌ 修复过程中出现错误: {e}")
            import traceback
            traceback.print_exc()
            return False

def main():
    parser = argparse.ArgumentParser(description='修复EPUB文件封面，使其在微信读书中正确显示')
    parser.add_argument('epub_file', help='要修复的EPUB文件路径')
    parser.add_argument('-o', '--output', help='输出文件路径（可选）')
    
    args = parser.parse_args()
    
    if not os.path.exists(args.epub_file):
        print(f"❌ 文件不存在: {args.epub_file}")
        return 1
    
    with EPUBCoverFixer(args.epub_file) as fixer:
        result = fixer.fix_cover(args.output)
        if result:
            print("\n✅ 修复成功！现在可以在微信读书中正确显示封面了。")
            return 0
        else:
            print("\n❌ 修复失败！")
            return 1

if __name__ == '__main__':
    exit(main()) 