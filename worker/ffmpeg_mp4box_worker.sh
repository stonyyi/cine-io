echo $PATH
echo ---------------------------------------------
echo $(find ./vidtools/bin)
echo ---------------------------------------------
echo $LD_LIBRARY_PATH
echo ---------------------------------------------
echo $(find ./vidtools/lib)
echo ---------------------------------------------
lsb_release -a
echo ---------------------------------------------
uname -r
echo ---------------------------------------------
ldd --version
echo ---------------------------------------------
ffmpeg -version
echo ---------------------------------------------
MP4Box -version
echo ---------------------------------------------
which MP4Box
echo ---------------------------------------------
ldd ./vidtools/bin/ffmpeg
echo ---------------------------------------------
ldd ./vidtools/bin/MP4Box