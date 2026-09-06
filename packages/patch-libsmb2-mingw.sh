#!/usr/bin/env bash
set -euo pipefail

src_dir=${1:?libsmb2 source directory is required}

header="$src_dir/include/smb2/libsmb2.h"
compat_h="$src_dir/lib/compat.h"
compat_c="$src_dir/lib/compat.c"
asprintf_h="$src_dir/include/asprintf.h"
socket_c="$src_dir/lib/socket.c"

# libsmb2 6.x needs a Windows socket type and the system types used by its
# public header when it is built with MinGW.
if ! grep -q '^#if !defined(_WIN32)$' "$header"; then
    sed -i 's/^typedef int t_socket;$/#if !defined(_WIN32)\ntypedef int t_socket;\n#endif/' "$header"
fi
if ! grep -q '^#include <stddef.h>$' "$header"; then
    sed -i '1i\
#include <time.h>\
#include <stdint.h>\
#include <stddef.h>\
#include "smb2.h"\
#if defined(_WIN32) && !defined(_WINDOWS)\
#include <winsock2.h>\
typedef SOCKET t_socket;\
#define SMB2_INVALID_SOCKET INVALID_SOCKET\
#endif' "$header"
fi

sed -i 's/^int random(void);$/long random(void);/' "$compat_h"
sed -i '/^int gethostname(char\* name, size_t len);$/d' "$compat_h"

if ! grep -q '^#include <stdlib.h>$' "$compat_c"; then
    sed -i '1i #include <stdlib.h>' "$compat_c"
fi
sed -i 's/return smb2_random();/return rand();/' "$compat_c"
sed -i 's/smb2_srandom(seed);/srand(seed);/' "$compat_c"
sed -i 's/return getpid_num();/return (int)GetCurrentProcessId();/' "$compat_c"
sed -i 's/return login_num;/buf[0] = 0; return 0;/' "$compat_c"
sed -i 's/^int random(void)/long random(void)/' "$compat_c"

if ! grep -q '^#ifndef __MINGW32__$' "$asprintf_h"; then
    sed -i '1i #ifndef __MINGW32__' "$asprintf_h"
    printf '%s\n' '#endif /* !__MINGW32__ */' >> "$asprintf_h"
fi
sed -i 's/#ifndef _MSC_VER/#if !defined(_MSC_VER) \&\& !defined(_WIN32)/' "$socket_c"
