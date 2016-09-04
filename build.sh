#!/bin/sh

ANDROID_NDK_DIR=
TARGET_PLATFORM=android-15

FEATURES="--enable-jni \
          --enable-mediacodec \
          --enable-decoder=h264 \
          --enable-decoder=h264_mediacodec \
          --enable-parser=h264 \
          --enable-demuxer=h264 \
          --enable-demuxer=mov \
          --enable-protocol=file"



HOST_OS=`basename $ANDROID_NDK_DIR/toolchains/*/prebuilt/* | head -n 1`


if [ "$ANDROID_NDK_DIR" = "" ]; then
	echo "ANDROID_NDK_DIR not provided. Please set it in script. Exiting..."
	exit 1
fi


function build
{
(
echo "BUILDING: $OUTPUT_DIR..."

cd ffmpeg;

OUTPUT_DIR=../android-builds/$OUTPUT_DIR

./configure \
    --prefix=$OUTPUT_DIR \
    --disable-shared \
    --enable-static \
    --enable-cross-compile \
    --cross-prefix=$ANDROID_NDK_DIR/toolchains/$TOOLCHAIN/prebuilt/$HOST_OS/bin/$EABIARCH- \
    --target-os=linux \
    --arch=$ARCH \
    --sysroot=$ANDROID_NDK_DIR/platforms/$TARGET_PLATFORM/arch-$ARCH/ \
    --extra-cflags="-Os -fpic $ADDI_CFLAGS" \
    --extra-ldflags="$ADDI_LDFLAGS" \
    --enable-memalign-hack \
    --disable-doc \
    --disable-ffmpeg \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-ffserver \
    --disable-symver \
    --disable-everything \
    $FEATURES \
    $ADDI_CONFIGURE_FLAG;

make clean;
make -j4;
make install

cat <<\EOF > "$OUTPUT_DIR/Android.mk"
LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE:= libavdevice
LOCAL_SRC_FILES:= lib/libavdevice.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE:= libavcodec
LOCAL_SRC_FILES:= lib/libavcodec.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE:= libavformat
LOCAL_SRC_FILES:= lib/libavformat.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE:= libswscale
LOCAL_SRC_FILES:= lib/libswscale.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE:= libavutil
LOCAL_SRC_FILES:= lib/libavutil.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE:= libavfilter
LOCAL_SRC_FILES:= lib/libavfilter.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE:= libswresample
LOCAL_SRC_FILES:= lib/libswresample.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include
include $(PREBUILT_STATIC_LIBRARY)
EOF
)
}


#arm v7 + neon (neon also include vfpv3-32)
TOOLCHAIN=arm-linux-androideabi-4.9
EABIARCH=arm-linux-androideabi
ARCH=arm
CPU=armv7-a
ADDI_CFLAGS="-mfloat-abi=softfp -mfpu=neon -marm -march=$CPU -mtune=cortex-a8 -mthumb -D__thumb__"
ADDI_LDFLAGS=
ADDI_CONFIGURE_FLAG="--enable-neon"
OUTPUT_DIR=armv7-a-neon
build

#arm v7vfpv3
TOOLCHAIN=arm-linux-androideabi-4.9
EABIARCH=arm-linux-androideabi
ARCH=arm
CPU=armv7-a
ADDI_CFLAGS="-mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=$CPU"
ADDI_LDFLAGS=
ADDI_CONFIGURE_FLAG=
OUTPUT_DIR=armv7-a
build

#arm v5
TOOLCHAIN=arm-linux-androideabi-4.9
EABIARCH=arm-linux-androideabi
ARCH=arm
CPU=armv5
ADDI_CFLAGS="-marm -march=$CPU"
ADDI_LDFLAGS=
ADDI_CONFIGURE_FLAG=
OUTPUT_DIR=arm
build

#x86
TOOLCHAIN=x86-4.9
EABIARCH=i686-linux-android
ARCH=x86
CPU=x86
ADDI_CFLAGS="-m32"
ADDI_LDFLAGS=
ADDI_CONFIGURE_FLAG="--disable-asm"
OUTPUT_DIR=x86
build

#mips
TOOLCHAIN=mipsel-linux-android-4.9
EABIARCH=mipsel-linux-android
ARCH=mips
CPU=mips32
ADDI_CFLAGS="-EL -march=$CPU -mips32 -mhard-float"
ADDI_LDFLAGS=
ADDI_CONFIGURE_FLAG="--disable-mips32r2"
OUTPUT_DIR=mips32
build


echo "Finished. Exiting..."
