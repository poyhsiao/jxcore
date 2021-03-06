if [ $# -eq 0 ]
then
  echo "no argument provided."
  echo "usage: android_configure <ndk_path>\n"
  exit
fi

export TOOLCHAIN=$PWD/android-toolchain-arm
rm -rf $TOOLCHAIN
mkdir -p $TOOLCHAIN
$1/build/tools/make-standalone-toolchain.sh \
    --toolchain=arm-linux-androideabi-4.9 \
    --arch=arm \
    --install-dir=$TOOLCHAIN \
    --platform=android-9
    
rm $TOOLCHAIN/bin/python

export TOOLCHAIN_INTEL=$PWD/android-toolchain-intel
rm -rf $TOOLCHAIN_INTEL
mkdir -p $TOOLCHAIN_INTEL
$1/build/tools/make-standalone-toolchain.sh \
    --toolchain=x86-4.8 \
    --arch=x86 \
    --install-dir=$TOOLCHAIN_INTEL \
    --platform=android-9
    
rm $TOOLCHAIN_INTEL/bin/python

export TOOLCHAIN_INTEL64=$PWD/android-toolchain-intelx64
rm -rf $TOOLCHAIN_INTEL64
mkdir -p $TOOLCHAIN_INTEL64
$1/build/tools/make-standalone-toolchain.sh \
    --toolchain=x86_64-4.9 \
    --arch=x86_64 \
    --install-dir=$TOOLCHAIN_INTEL64 \
    --platform=android-21
    
rm $TOOLCHAIN_INTEL64/bin/python

export TOOLCHAIN=$PWD/android-toolchain-arm64
rm -rf $TOOLCHAIN
mkdir -p $TOOLCHAIN
$1/build/tools/make-standalone-toolchain.sh \
    --toolchain=aarch64-linux-android-4.9 \
    --arch=arm64 \
    --install-dir=$TOOLCHAIN \
    --platform=android-21
    
rm $TOOLCHAIN/bin/python
    
echo "Android tools are ready. Now call 'build_scripts/android_compile.sh'"