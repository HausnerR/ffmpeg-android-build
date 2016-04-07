# ffmpeg-android-build

Build script for cross compile ffmpeg for Android. It generates libs for all platforms (except 64 bit).

Works with latest version of ffmpeg and Android NDK (7 april 2016).

## requirements

Installed Android NDK and propably that's all.

## howto

1. Clone this repo
2. Execute *git submodule init && git submodule update*
3. Set **ANDROID_NDK_DIR** and **FEATURES** in build.sh
4. Run *./build.sh*
5. Static libraries should be generated and ready to use in *android-builds* directory

##inspiration

- (http://enoent.fr/blog/2014/06/20/compile-ffmpeg-for-android/)
- (https://github.com/appunite/AndroidFFmpeg)

