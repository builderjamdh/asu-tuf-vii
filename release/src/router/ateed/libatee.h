/*
 * Copyright © 2023 ASUSTeK COMPUTER INC. All rights reserved.
 */

#ifndef __LIBATEE_H__
#define __LIBATEE_H__

#include <stdio.h>

#define ATEED_SOCKET_PATH "/var/run/ateed_socket"


enum {
	ATEE_S_CLEAR_ALL = 0,
	ATEE_S_CHECK_DEF_PW,
	ATEE_S_CHECK_USER_PW,
	ATEE_S_CHECK_APP_PW,
	ATEE_S_CHECK_COMMON_DATA,
	ATEE_S_MATCH_ADM_PW,
	ATEE_S_MATCH_ADM_DEF_PW,
	ATEE_S_MATCH_ADM_USER_PW,
	ATEE_S_MATCH_ADM_APP_PW,
	ATEE_S_SET_DEF_PW,
	ATEE_S_SET_USER_PW,
	ATEE_S_SET_APP_PW,
	ATEE_S_SET_COMMON_DATA,
	ATEE_S_SET_USER_PW_AS_DEF_PW,
	ATEE_S_GET_ADM_CRYPT,
	ATEE_S_GET_ADM_PW,
	ATEE_S_GET_USER_PW,
	ATEE_S_GET_USER_PW_MD5,
	ATEE_S_GET_APP_PW_MD5,
	ATEE_S_GET_COMMON_DATA,
};

enum {
	ATEE_COMMON_DATA_N = 0,
	ATEE_COMMON_DATA_MAX
};

typedef struct atee_sock_data {
	int d_type;
	union {
		char data[64];
		struct {
			int c_type;
			size_t c_len;
			uint8_t c_data[64];
		};
	};
} atee_sock_data_t;


int atee_clear_all();

int atee_check_admin_def_pw_exist();
int atee_check_admin_user_pw_exist();
int atee_check_admin_app_pw_exist();
int atee_check_common_data_exist(int data_type);

int atee_check_admin_pw_match(const char *pw);
int atee_check_admin_def_pw_match(const char *pw);
int atee_check_admin_user_pw_match(const char *pw);
int atee_check_admin_app_pw_match(const char *pw);

int atee_set_admin_def_pw(const char *pw);
int atee_set_admin_user_pw(const char *pw);
int atee_set_admin_app_pw(const char *pw);
int atee_set_common_data(int data_type, const void *data, size_t data_len);
int atee_set_admin_user_pw_as_def_pw();

char *atee_get_admin_crypt(const char *salt, char *out, size_t out_len);
char *atee_get_admin_pw(char *out, size_t out_len);
char *atee_get_admin_user_pw(char *out, size_t out_len);
char *atee_get_admin_user_pw_md5(char *out, size_t out_len);
char *atee_get_admin_app_pw_md5(char *out, size_t out_len);
uint8_t *atee_get_common_data(int data_type, uint8_t *out, size_t out_len);

#endif	//__LIBATEE_H__
