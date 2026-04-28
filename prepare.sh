#!/bin/bash
id
df -h
free -h
cat /proc/cpuinfo

if [ -d "lede" ]; then
    echo "repo dir exists"
    cd lede
    echo ">>> 检查并尝试安装隐藏的 DRM 依赖包"
# 检查 kmod-drm-shmem-helper 的 Makefile 是否存在
if [ -f "package/kernel/linux/modules/video.mk" ] && grep -q "kmod-drm-shmem-helper" package/kernel/linux/modules/video.mk; then
    echo "找到隐藏包 drm-shmem-helper 的定义，尝试激活。"
    # 查找并执行 Makefile 中的 install 指令，强制使其在后续编译中可用
    make package/kernel/linux/compile -j1 V=s 2>/dev/null || true
else
    echo "警告：未找到 drm-shmem-helper 的 Makefile，可能需要检查内核配置。"
fi
    git reset --hard
    git pull || { echo "git pull failed"; exit 1; }
else
    echo "repo dir not exists"
    git clone "https://github.com/coolsnowwolf/lede.git" || { echo "git clone failed"; exit 1; }
    cd lede
fi

cat feeds.conf.default > feeds.conf
echo "" >> feeds.conf
echo "src-git qmodem https://github.com/FUjr/QModem.git;main" >> feeds.conf
#echo "src-git qmodem https://github.com/zzzz0317/QModem.git;stable202508" >> feeds.conf
echo "src-git istore https://github.com/linkease/istore;main" >> feeds.conf
echo "src-git nas https://github.com/linkease/nas-packages.git;master" >> feeds.conf
echo "src-git nas_luci https://github.com/linkease/nas-packages-luci.git;main" >> feeds.conf
rm -rf files
cp -r ../files .
if [ -d "package/zz/luci-app-argon-config" ]; then
    cd package/zz/luci-app-argon-config
    git pull || { echo "luci-app-argon-config git pull failed"; exit 1; }
    cd ../../..
else
    git clone https://github.com/jerrykuku/luci-app-argon-config.git package/zz/luci-app-argon-config || { echo "luci-app-argon-config git clone failed"; exit 1; }
fi
if [ -d "package/zz/luci-theme-alpha" ]; then
    cd package/zz/luci-theme-alpha
    git pull || { echo "luci-theme-alpha git pull failed"; exit 1; }
    cd ../../..
else
    git clone https://github.com/derisamedia/luci-theme-alpha.git package/zz/luci-theme-alpha || { echo "luci-theme-alpha git clone failed"; exit 1; }
fi
if [ -d "package/zz/xgp-v3-screen" ]; then
    cd package/zz/xgp-v3-screen
    git pull || { echo "xgp-v3-screen git pull failed"; exit 1; }
    cd ../../..
else
    git clone https://github.com/junhong-l/xgp-v3-screen.git package/zz/xgp-v3-screen || { echo "xgp-v3-screen git clone failed"; exit 1; }
fi
