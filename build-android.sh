#!/bin/bash

#设置ANDROID_NDK的根目录
NDK_ROOT=/Users/ZhengYi/Public/android-ndk-r10

#ffmpeg库的输出路径
DEST_DIR=$(cd $(dirname $0); pwd)/android/arm

#兼容arm-v7需要额外设置的Flag
EXTRA_CFLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16"
EXTRA_LDFLAGS="-march=armv7-a -Wl,--fix-cortex-a8"

#自定义工具链的配置信息，根据系统环境做相应调整
#目标版本
TARGET_PLATFORM=Android-L
#目标工具链
TARGET_TOOLCHAIN=arm-linux-androideabi-4.9
#自定义工具链的输出路径
TARGET_INSTALL_DIR=/tmp/android-toolchains/arm


function main_entry {
    
    #初始化
    ffmpeg_dir=$(dirname $0)/src/ffmpeg
    if [ -d $ffmpeg_dir ] ;then
    echo "初始化完毕"
    else
    git clone git://source.ffmpeg.org/ffmpeg.git $ffmpeg_dir
    echo "初始化完毕"
    fi

    #构建自定义工具链
    toolchain_builder=${NDK_ROOT}/build/tools/make-standalone-toolchain.sh
    
    sh $toolchain_builder \
        --ndk-dir=$NDK_ROOT \
        --platform=$TARGET_PLATFORM \
        --toolchain=$TARGET_TOOLCHAIN \
        --install-dir=$TARGET_INSTALL_DIR
    
    base_dir=$(dirname $0)
    cd $base_dir/src/ffmpeg
    
    ##配置ffmpeg
    ./configure \
        --prefix=$DEST_DIR \
        --enable-shared \
        --enable-static \
        --disable-doc \
        --disable-ffmpeg \
        --disable-ffplay \
        --disable-ffprobe \
        --disable-ffserver \
        --disable-avdevice \
        --disable-doc \
        --disable-symver \
        --cross-prefix=${TARGET_INSTALL_DIR}/bin/arm-linux-androideabi- \
        --target-os=android \
        --arch=arm \
        --enable-cross-compile \
        --sysroot=${TARGET_INSTALL_DIR}/sysroot \
        --extra-cflags="$EXTRA_CFLAGS" \
        --extra-ldflags="$EXTRA_LDFLAGS"
    ##编译ffmpeg
    make -j4
    make install
    
    cd -
}

#Script Logic
if [ -d $NDK_ROOT ] ;then
main_entry
else
script_name=`basename $0`
echo "请配置 $script_name 中的变量NDK_ROOT"
fi
exit
