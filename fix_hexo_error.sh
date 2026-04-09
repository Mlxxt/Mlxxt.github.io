#!/bin/bash
echo "=== 修复 Hexo FATAL 错误 ==="
echo

# 检查是否在项目目录
if [ ! -f "_config.yml" ]; then
    echo "错误：请在 Hexo 项目目录中运行此脚本"
    echo "当前目录：$(pwd)"
    exit 1
fi

echo "1. 备份当前依赖配置..."
cp package.json package.json.backup
echo "   备份已保存到: package.json.backup"

echo -e "\n2. 清理旧文件..."
rm -rf node_modules
rm -f package-lock.json
echo "   ✓ 已清理"

echo -e "\n3. 检查 Node.js 版本..."
NODE_VERSION=$(node --version | cut -d'.' -f1 | tr -d 'v')
echo "   当前 Node.js 版本: v$NODE_VERSION"

if [ "$NODE_VERSION" -ge 18 ]; then
    echo "   警告：Node.js 版本 >= 18 可能与某些 Hexo 插件不兼容"
    echo "   建议使用 Node.js 16 LTS"
    read -p "   是否继续？(y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "   请先安装 Node.js 16: nvm install 16 && nvm use 16"
        exit 1
    fi
fi

echo -e "\n4. 更新 package.json 中的依赖版本..."
# 创建临时文件
cat > package.tmp.json << 'PKG'
{
  "name": "hexo-site",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "build": "hexo generate",
    "clean": "hexo clean",
    "deploy": "hexo deploy",
    "server": "hexo server"
  },
  "hexo": {
    "version": "6.3.0"
  },
  "dependencies": {
    "hexo": "^6.3.0",
    "hexo-deployer-git": "^4.0.0",
    "hexo-generator-archive": "^1.0.0",
    "hexo-generator-category": "^1.0.0",
    "hexo-generator-index": "^2.0.0",
    "hexo-generator-tag": "^1.0.0",
    "hexo-renderer-ejs": "^2.0.0",
    "hexo-renderer-marked": "^5.0.0",
    "hexo-renderer-stylus": "^2.0.0",
    "hexo-server": "^3.0.0"
  }
}
PKG

# 合并现有配置
if [ -f "package.json" ]; then
    # 保留原有的一些配置
    jq -s '.[0] * .[1]' package.tmp.json package.json > package.new.json 2>/dev/null || cp package.tmp.json package.new.json
    mv package.new.json package.json
    rm package.tmp.json
    echo "   ✓ package.json 已更新"
else
    mv package.tmp.json package.json
    echo "   ✓ 创建了新的 package.json"
fi

echo -e "\n5. 安装依赖..."
npm install
echo "   ✓ 依赖安装完成"

echo -e "\n6. 安装 hexo-cli 全局（可选）..."
npm install -g hexo-cli@4.3.0
echo "   ✓ hexo-cli 已安装"

echo -e "\n7. 修复 strip-ansi 问题..."
npm install strip-ansi@6.0.1 --save
echo "   ✓ strip-ansi 版本已固定"

echo -e "\n8. 测试 Hexo..."
if npx hexo version 2>/dev/null; then
    echo "   ✓ Hexo 可以正常运行！"
    echo "   版本: $(npx hexo version)"
else
    echo "   ✗ Hexo 仍然无法运行"
    echo "   尝试另一种方法..."
    
    # 尝试清理缓存
    npm cache clean --force
    rm -rf node_modules
    npm install --legacy-peer-deps
fi

echo -e "\n=== 修复完成 ==="
echo "可以尝试运行: npx hexo clean && npx hexo server"
