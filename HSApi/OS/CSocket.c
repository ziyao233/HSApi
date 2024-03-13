/*
 *	HSApi
 *	/HSApi/OS/CSocket.c
 *	This file is distributed under Mozilla Public License Version 2.0
 *	Copyright (c) 2024 Yao Zi. All rights reserved.
 */

#include<errno.h>
#include<unistd.h>
#include<sys/socket.h>
#include<arpa/inet.h>
#include<netinet/in.h>

int
hsapi_socket(void)
{
	return socket(AF_INET6, SOCK_STREAM, 0);
}

int
hsapi_bind(int sock, const char *addr, int port)
{
	struct sockaddr_in6 in = {
					.sin6_family	= AF_INET6,
					.sin6_port	= htons(port),
				 };
	switch (inet_pton(AF_INET6, addr, &in.sin6_addr)) {
	case 0:
		errno = -EINVAL;
		return -1;
	case -1:
		return -1;
	}
	return bind(sock, (struct sockaddr *)&in, sizeof(struct sockaddr_in6));
}

int
hsapi_listen(int sock, int backlog)
{
	return listen(sock, backlog);
}

int
hsapi_accept(int sock)
{
	return accept(sock, NULL, NULL);
}
