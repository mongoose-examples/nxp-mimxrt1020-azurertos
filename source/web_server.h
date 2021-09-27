// Copyright (c) 2021 Cesanta Software Limited
// All rights reserved

#ifndef WEB_SERVER_H_
#define WEB_SERVER_H_

#define SAMPLE_IPV4_ADDRESS         IP_ADDRESS(192, 168, 0, 10)
#define SAMPLE_IPV4_MASK            0xFFFFFF00UL
#define SAMPLE_GATEWAY_ADDRESS      IP_ADDRESS(192, 168, 0, 255)

void mg_run_server();

#endif /* WEB_SERVER_H_ */
