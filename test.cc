#include <stdio.h>
#include <unistd.h>

void main()
{
	char s[100];
	int d;

	d=0;
	scanf("%[^\n]%n", &s, &d);
	printf("%d\n", d);
	s[d] = 0x0;
	printf("%s\n", s);
}
