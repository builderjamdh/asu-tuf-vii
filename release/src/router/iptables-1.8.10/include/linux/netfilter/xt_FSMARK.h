#ifndef _XT_FSMARK_H
#define _XT_FSMARK_H

#include <linux/types.h>

#define MAX_NF_FSMARK_QUERIES         128    // FSMARK query ID 0..127

struct xt_fsmark_tginfo {
    __u8    id;
    __u8    flags;
};

#define XT_FSMARK_VALID_ID      0x01

#endif /*_XT_FSMARK_H*/
