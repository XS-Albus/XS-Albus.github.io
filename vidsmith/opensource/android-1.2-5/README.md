# FFmpeg 6.1.6

Vidsmith dynamically links FFmpeg's libavformat, libavcodec, and libavutil for QuickTime MOV packaging. The libraries are built under the GNU Lesser General Public License, version 2.1 or later. See COPYING.LGPLv2.1.

The build uses the unmodified FFmpeg 6.1.6 source archive at https://ffmpeg.org/releases/ffmpeg-6.1.6.tar.xz. SHA-256: d4fcb164028dd3beee5d92c0ac72e46aac6973c75ea12dc14de07bf8f407370a. The exact configure flags and build instructions are in android/scripts/mov/build_libraries.sh. The build enables the MOV demuxer and muxer and the file protocol, with no external libraries or GPL/nonfree options.

For public distribution, publish the matching source archive and build script alongside the application distribution and include the FFmpeg attribution in the applicable download and license terms. See https://ffmpeg.org/legal.html.
