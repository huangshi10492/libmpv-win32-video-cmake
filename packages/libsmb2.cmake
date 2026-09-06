set(libsmb2_pc ${CMAKE_CURRENT_BINARY_DIR}/libsmb2.pc)
file(WRITE ${libsmb2_pc}
"prefix=${MINGW_INSTALL_PREFIX}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: libsmb2
Description: SMB2/3 client library
Version: 6.0.0
Libs: -L\${libdir} -lsmb2 -lws2_32
Cflags: -I\${includedir} -I\${includedir}/smb2
")

ExternalProject_Add(libsmb2
    GIT_REPOSITORY https://github.com/sahlberg/libsmb2.git
    SOURCE_DIR ${SOURCE_LOCATION}
    GIT_CLONE_FLAGS "--filter=tree:0"
    GIT_TAG v6.0.0
    UPDATE_COMMAND ""
    PATCH_COMMAND bash ${CMAKE_CURRENT_SOURCE_DIR}/patch-libsmb2-mingw.sh <SOURCE_DIR>
    CONFIGURE_COMMAND ${EXEC} CONF=1 cmake -H<SOURCE_DIR> -B<BINARY_DIR>
        -G Ninja
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
        -DCMAKE_INSTALL_PREFIX=${MINGW_INSTALL_PREFIX}
        -DCMAKE_FIND_ROOT_PATH=${MINGW_INSTALL_PREFIX}
        -DCMAKE_INSTALL_LIBDIR=lib
        -DBUILD_SHARED_LIBS=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
    BUILD_COMMAND ${EXEC} ninja -C <BINARY_DIR>
    INSTALL_COMMAND ${EXEC} ninja -C <BINARY_DIR> install
        COMMAND ${CMAKE_COMMAND} -E copy ${libsmb2_pc} ${MINGW_INSTALL_PREFIX}/lib/pkgconfig/libsmb2.pc
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

force_rebuild_git(libsmb2)
cleanup(libsmb2 install)
