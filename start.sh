#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/layeredge.sh"

# 检测并安装环境依赖
function install_dependencies() {
    echo "正在检测系统环境依赖..."

    # 检测并安装 git
    if ! command -v git &> /dev/null; then
        echo "未找到 git，正在安装 git..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y git
        elif command -v yum &> /dev/null; then
            sudo yum install -y git
        elif command -v brew &> /dev/null; then
            brew install git
        else
            echo "无法自动安装 git，请手动安装 git 后重试。"
            exit 1
        fi
        echo "git 安装完成！"
    else
        echo "git 已安装。"
    fi

    # 检测并安装 node 和 npm
    if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
        echo "未找到 node 或 npm，正在安装 node 和 npm..."
        if command -v apt-get &> /dev/null; then
            curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
            sudo apt-get install -y nodejs
        elif command -v yum &> /dev/null; then
            curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo -E bash -
            sudo yum install -y nodejs
        elif command -v brew &> /dev/null; then
            brew install node
        else
            echo "无法自动安装 node 和 npm，请手动安装 node 和 npm 后重试。"
            exit 1
        fi
        echo "node 和 npm 安装完成！"
    else
        echo "node 和 npm 已安装。"
    fi

    echo "环境依赖检测完成！"
}

# 部署 layeredge 节点
function deploy_layeredge_node() {
    # 检测并安装环境依赖
    install_dependencies

    # 拉取仓库
    echo "正在拉取仓库..."

    # 拉取仓库
    if git clone https://github.com/sdohuajia/LayerEdge.git; then
    echo "仓库拉取成功！"
    else
    echo "仓库拉取失败，请检查网络连接或仓库地址。"
    exit 1
    fi

    # 进入目录
    echo "进入项目目录..."
    cd LayerEdge

    # 输入钱包信息（如果需要）
    # read -p "钱包地址：" wallet_address
    # read -p "私钥：" private_key
    # 将钱包信息写入 wallets.txt
    echo "$wallet_address,$private_key" >> wallets.txt
    echo "钱包信息已保存。"

    # 安装依赖
    echo "正在使用 npm 安装依赖..."
    if npm install; then
    echo "依赖安装成功！"
    else
    echo "依赖安装失败，请检查网络连接或 npm 配置。"
    exit 1
    fi

    # 提示用户操作完成
    echo "操作完成！代理已保存到 proxy.txt，钱包已保存到 wallets.txt，依赖已安装。"

    # 启动项目
    echo "正在启动项目..."
    # screen -S layer -dm bash -c "cd ~/LayerEdge && npm start"  # 在 screen 会话中启动 npm start
    screen -S layer -dm bash -c "cd ~/LayerEdge && npm start; exec > >(tee -a ~/LayerEdge/screenlog.txt) 2>&1"
    echo "项目已在 screen 会话中启动。"
    echo "你可以使用以下命令查看运行状态："
    echo "screen -r layer"
    echo "如果需要退出 screen 会话而不终止进程，请按 Ctrl + A，然后按 D 键。"
}

deploy_layeredge_node
