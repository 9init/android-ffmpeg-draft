#!/bin/bash
BASEDIR=$(pwd)
TOOLCHAIN=/home/hesham/my-android-toolchain
SYSROOT_L=$TOOLCHAIN/sysroot/usr/lib/aarch64-linux-android
GCC_L=/home/hesham/Android/Sdk/ndk/22.1.7171670/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/lib/gcc/aarch64-linux-android/4.9.x
CFLAGS='-fPIC'
LDFLAGS='-Wl,-z,relro -Wl,-z,now -pie'
API='30'
ARCH='aarch64'
OUTPUT=~/arm64-v8a

build(){
    ./configure \
    --disable-everything \
    --disable-network \
    --disable-autodetect \
    --enable-small \
    --enable-demuxer=mov,m4v,matroska \
    --enable-muxer=mp3,mp4,webm,ogg,opus \
    --enable-protocol=file \
    --target-os=android \
    --prefix=$OUTPUT \
    --arch=$ARCH \
    --sysroot=$TOOLCHAIN/sysroot \
    --enable-static \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-debug \
    --disable-doc \
    --disable-avdevice \
    --disable-shared \
    --enable-cross-compile \
    --cross-prefix=$TOOLCHAIN/bin/aarch64-linux-android- \
    --cc=$TOOLCHAIN/bin/aarch64-linux-android$API-clang \
    --cxx=$TOOLCHAIN/bin/aarch64-linux-android$API-clang++ \
    --extra-cflags="-fpic -I$OUTPUT/include" \
    # --extra-ldflags="-lc -ldl -lm -lz -llog -lgcc -L$OUTPUT/lib"
  
    #--enable-filter=aresample \
    #--enable-cross-compile \
    #--toolchain=clang-usan \
    #--cross-prefix=${TOOLCHAIN_DIR}/bin/arm-linux-androideabi- \
    #--cc=${TOOLCHAIN_DIR}/bin/arm-linux-androideabi-clang \
    #--sysroot=${TOOLCHAIN_DIR}/sysroot \
    #--target-os=android \
    #--disable-doc \
    #--disable-shared \
    #--enable-static \
    #--extra-cflags=$CFLAGS \
    #--arch="arm"
    #--enable-decoder=aac*,ac3*,opus,vorbis,ogg,av1 \
    #--extra-ldflags="-L${TOOLCHAIN_PREFIX}/lib $LDFLAGS" \

    make clean all
    make -j12
    make install
}

package_library() {
    $TOOLCHAIN/bin/ld -rpath-link=$SYSROOT_L/$API \
    -L$SYSROOT_L/$API -L$OUTPUT/lib \
    -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o $OUTPUT/libffmpeg.so \
    $OUTPUT/lib/libavcodec.a \
    $OUTPUT/lib/libavfilter.a \
    $OUTPUT/lib/libavformat.a \
    $OUTPUT/lib/libavutil.a \
    $OUTPUT/lib/libswresample.a \
    $OUTPUT/lib/libswscale.a \
    $GCC_L/libgcc.a \
    -lc -ldl -lm -lz -llog \
    --dynamic-linker=/system/bin/linker
    #  Set dynamic linker , Different platforms ,android  It uses /system/bin/linker
}

build
package_library
