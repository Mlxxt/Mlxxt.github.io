#!/bin/bash
# 安装 nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 使用 Node.js 16
nvm install 16
nvm use 16

# 修复项目
cd ~/Project/Web/MyBlog
rm -rf node_modules package-lock.json
npm install hexo@6.3.0 hexo-cli@4.3.0 strip-ansi@6.0.1 --save
npm install

echo "修复完成！尝试运行：npx hexo clean"
