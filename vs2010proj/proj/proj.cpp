// proj.cpp : �������̨Ӧ�ó������ڵ㡣
//

#include "stdafx.h"

#ifdef _DEBUG
#define	TEST_STR	("debug")
#else
#define TEST_STR	("no debug")
#endif

int _tmain(int argc, _TCHAR* argv[])
{
	printf("%s\n", TEST_STR);
	return 0;
}

