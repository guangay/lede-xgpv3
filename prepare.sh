bash
#!/bin/bash
id
df -h
free -h
cat /proc/cpuinfo

if [ -d "lede" ]; then
    echo "repo dir exists"
    cd lede
    git reset --hard
    git pull || { echo "git pull failed"; exit 1; }
else
    echo "repo dir not exists"
    git clone "https://github.com/coolsnowwolf/lede.git" || { echo "git clone failed"; exit 1; }
    cd lede
fi

# 修复 DRM_SHMEM_HELPER 缺失，必须以模块方式编译
sed -i '/^CONFIG_DRM_SHMEM_HELPER/d' target/linux/rockchip/armv8/config-6.12
echo 'CONFIG_DRM_SHMEM_HELPER=m' >> target/linux/rockchip/armv8/config-6.12
# 修复 kmod-drm-panfrost 依赖 drm_shmem_helper.ko 的问题（OpenWrt 6.12 内核 BUG）
sed -i 's|FILES:=\$(LINUX_DIR)/drivers/gpu/drm/panfrost/panfrost.ko|FILES:=\$(LINUX_DIR)/drivers/gpu/drm/panfrost/panfrost.ko \$(LINUX_DIR)/drivers/gpu/drm/drm_shmem_helper.ko|g' package/kernel/linux/modules/video.mk


cat feeds.conf.default > feeds.conf
echo "" >> feeds.conf
echo "src-git qmodem https://github.com/FUjr/QModem.git;main" >> feeds.conf
# iStore 源绝对不能少，否则 luci-app-store 无法编译
echo "src-git istore https://github.com/linkease/istore;main" >> feeds.conf
echo "src-git nas https://github.com/linkease/nas-packages.git;master" >> feeds.conf
echo "src-git nas_luci https://github.com/linkease/nas-packages-luci.git;main" >> feeds.conf

rm -rf files
cp -r ../files .

# 主题
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

# 屏幕控制程序（使用你指定的 junhong-l 版本，内置驱动，无需单独 kmod-fb-tft-gc9307）
if [ -d "package/zz/xgp-v3-screen" ]; then
    cd package/zz/xgp-v3-screen
    git pull || { echo "xgp-v3-screen git pull failed"; exit 1; }
    cd ../../..
else
    git clone https://github.com/junhong-l/xgp-v3-screen.git package/zz/xgp-v3-screen || { echo "xgp-v3-screen git clone failed"; exit 1; }
fi

# 更新 feeds 并强制安装必需包
./scripts/feeds update -a
./scripts/feeds install -d y -p nas_luci luci-app-quickstart
./scripts/feeds install -d y -p istore luci-app-store
