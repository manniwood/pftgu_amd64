#include <stdio.h>

/* leaf function */
int add_more(int a, int b) {
	int x = a;
	int y = b;
	int answer = x + y;
	return answer;
}


/* function */
int add(int a, int b) {
	int x = a;
	int y = b;
	int z = add_more(25, 76);
	int answer = x + y + z;
	return answer;
}

int main() {
	add(77, 88);
	return 0;
}
