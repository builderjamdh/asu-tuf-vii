/*
 *  cloud_control.h - 华硕云控总开关
 *  魔改固件新增: 通过 NVRAM asus_cloud_enable 一键控制所有 ASUS 云服务
 */
#ifndef _CLOUD_CONTROL_H_
#define _CLOUD_CONTROL_H_

#include "rc.h"

/* 检查云服务是否被全局禁用 */
static inline int cloud_disabled(void)
{
	return nvram_match("asus_cloud_enable", "0");
}

/* 检查云服务是否启用 */
static inline int cloud_enabled(void)
{
	return nvram_match("asus_cloud_enable", "1");
}

#endif /* _CLOUD_CONTROL_H_ */
