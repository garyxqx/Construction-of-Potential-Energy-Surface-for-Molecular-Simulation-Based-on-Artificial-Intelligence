#!/bin/bash

# ============================================================================
# Gaussian自动识别和配置脚本
# 自动检测系统中可用的Gaussian版本并设置相应环境变量
# ============================================================================

echo "🔍 正在检测系统中的Gaussian版本..."

# 检测可用的Gaussian版本
GAUSSIAN_CMD=""
GAUSSIAN_VERSION=""
GAUSS_SCRDIR=""

# 检查g16是否可用
if command -v g16 >/dev/null 2>&1; then
    GAUSSIAN_CMD="g16"
    GAUSSIAN_VERSION="Gaussian 16"
    echo "✅ 检测到 Gaussian 16 (g16)"
    
    # 获取g16的安装路径
    G16_PATH=$(which g16)
    echo "📍 g16路径: $G16_PATH"
    
    # 尝试自动设置GAUSS_SCRDIR
    if [ -n "$G16_PATH" ]; then
        # 常见的scratch目录位置
        possible_scratch_dirs=(
            "/tmp/gaussian_scratch"
            "/scratch/gaussian"
            "/home/$USER/gaussian/scratch"
            "/home/$USER/.gaussian/scratch"
            "/var/tmp/gaussian_scratch"
            "/tmp"
        )
        
        for dir in "${possible_scratch_dirs[@]}"; do
            if [ -d "$dir" ] || mkdir -p "$dir" 2>/dev/null; then
                if [ -w "$dir" ]; then
                    GAUSS_SCRDIR="$dir"
                    echo "✅ 设置GAUSS_SCRDIR为: $GAUSS_SCRDIR"
                    break
                fi
            fi
        done
        
        # 如果还是没找到合适的目录，使用临时目录
        if [ -z "$GAUSS_SCRDIR" ]; then
            GAUSS_SCRDIR="/tmp/gaussian_scratch_$$"
            mkdir -p "$GAUSS_SCRDIR"
            echo "⚠️  使用临时scratch目录: $GAUSS_SCRDIR"
        fi
    fi

# 检查g09是否可用
elif command -v g09 >/dev/null 2>&1; then
    GAUSSIAN_CMD="g09"
    GAUSSIAN_VERSION="Gaussian 09"
    echo "✅ 检测到 Gaussian 09 (g09)"
    
    # 获取g09的安装路径
    G09_PATH=$(which g09)
    echo "📍 g09路径: $G09_PATH"
    
    # 尝试自动设置GAUSS_SCRDIR
    if [ -n "$G09_PATH" ]; then
        # 常见的scratch目录位置
        possible_scratch_dirs=(
            "/tmp/gaussian_scratch"
            "/scratch/gaussian"
            "/home/$USER/gaussian/scratch"
            "/home/$USER/.gaussian/scratch"
            "/var/tmp/gaussian_scratch"
            "/tmp"
        )
        
        for dir in "${possible_scratch_dirs[@]}"; do
            if [ -d "$dir" ] || mkdir -p "$dir" 2>/dev/null; then
                if [ -w "$dir" ]; then
                    GAUSS_SCRDIR="$dir"
                    echo "✅ 设置GAUSS_SCRDIR为: $GAUSS_SCRDIR"
                    break
                fi
            fi
        done
        
        # 如果还是没找到合适的目录，使用临时目录
        if [ -z "$GAUSS_SCRDIR" ]; then
            GAUSS_SCRDIR="/tmp/gaussian_scratch_$$"
            mkdir -p "$GAUSS_SCRDIR"
            echo "⚠️  使用临时scratch目录: $GAUSS_SCRDIR"
        fi
    fi

# 检查g03是否可用（旧版本）
elif command -v g03 >/dev/null 2>&1; then
    GAUSSIAN_CMD="g03"
    GAUSSIAN_VERSION="Gaussian 03"
    echo "✅ 检测到 Gaussian 03 (g03)"
    
    # 获取g03的安装路径
    G03_PATH=$(which g03)
    echo "📍 g03路径: $G03_PATH"
    
    # 设置scratch目录
    GAUSS_SCRDIR="/tmp/gaussian_scratch_$$"
    mkdir -p "$GAUSS_SCRDIR"
    echo "⚠️  使用临时scratch目录: $GAUSS_SCRDIR"

else
    echo "❌ 错误：未检测到任何Gaussian版本！"
    echo "请确保已安装Gaussian并添加到PATH环境变量中"
    echo "支持的版本：g16, g09, g03"
    exit 1
fi

# 设置环境变量
export GAUSS_SCRDIR="$GAUSS_SCRDIR"
echo "🔧 环境变量设置完成："
echo "   GAUSS_SCRDIR=$GAUSS_SCRDIR"
echo "   GAUSSIAN_CMD=$GAUSSIAN_CMD"
echo "   GAUSSIAN_VERSION=$GAUSSIAN_VERSION"

# 检查scratch目录权限
if [ ! -w "$GAUSS_SCRDIR" ]; then
    echo "⚠️  警告：scratch目录 $GAUSS_SCRDIR 不可写"
    echo "尝试修复权限..."
    chmod 755 "$GAUSS_SCRDIR" 2>/dev/null || {
        echo "❌ 无法修复scratch目录权限，请手动设置"
        exit 1
    }
fi

echo ""
echo "🚀 开始处理Gaussian输入文件..."

# 统计文件数量
total_files=$(find . -name "*.gjf" | wc -l)
if [ $total_files -eq 0 ]; then
    echo "❌ 未找到任何.gjf文件！"
    echo "请先运行 generate_gaussian_input.py 生成输入文件"
    exit 1
fi

echo "📁 找到 $total_files 个输入文件"

# 计数器
success_count=0
fail_count=0

# 遍历所有输入文件
for input in */*/*.gjf
do
    # 检查文件是否存在
    if [ ! -f "$input" ]; then
        continue
    fi
    
    # 构建输出文件名
    output="${input%.gjf}.out"
    
    echo "🔄 正在处理: $input"
    
    # 检查磁盘空间
    disk_usage=$(df -h . | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 90 ]; then
        echo "⚠️  磁盘空间不足 (${disk_usage}%)，停止处理"
        break
    fi
    
    # 检查scratch目录空间
    scratch_usage=$(df -h "$GAUSS_SCRDIR" | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$scratch_usage" -gt 95 ]; then
        echo "⚠️  Scratch目录空间不足 (${scratch_usage}%)，清理中..."
        rm -rf "$GAUSS_SCRDIR"/* 2>/dev/null
        echo "✅ Scratch目录已清理"
    fi
    
    # 运行Gaussian
    echo "   🚀 启动 $GAUSSIAN_VERSION..."
    start_time=$(date +%s)
    
    if $GAUSSIAN_CMD < "$input" > "$output" 2>&1
    then
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        echo "   ✅ 处理成功 (耗时: ${duration}秒)"
        echo "   📄 输出文件: $output"
        ((success_count++))
        
        # 检查输出文件是否包含错误
        if grep -q "Error\|ERROR\|error" "$output"; then
            echo "   ⚠️  输出文件中包含错误信息"
        fi
    else
        echo "   ❌ 处理失败"
        echo "   📄 检查输出文件: $output"
        ((fail_count++))
    fi
    
    echo ""
done

# 清理临时scratch目录（如果是我们创建的）
if [[ "$GAUSS_SCRDIR" == *"gaussian_scratch_$$"* ]]; then
    echo "🧹 清理临时scratch目录..."
    rm -rf "$GAUSS_SCRDIR"
fi

# 输出统计信息
echo "=" * 60
echo "📊 处理完成！统计信息："
echo "   ✅ 成功: $success_count 个文件"
echo "   ❌ 失败: $fail_count 个文件"
echo "   📁 总计: $total_files 个文件"
echo "   🔧 使用版本: $GAUSSIAN_VERSION"
echo "   📍 Scratch目录: $GAUSS_SCRDIR"
echo "=" * 60

if [ $fail_count -gt 0 ]; then
    echo "⚠️  有 $fail_count 个文件处理失败，请检查输出文件"
    exit 1
else
    echo "🎉 所有文件处理成功！"
    exit 0
fi
