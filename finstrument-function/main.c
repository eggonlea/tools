int a(int n)
{
	if(n>0)
		return a(n-1);
	return n;
}

int b(int n)
{
	return a(n);
}

int c(int n)
{
	if(n>0)
		return a(n);
	else if(n<0)
		return b(n);
	else
		return n;
}

int main()
{
	int n=0;
	for(int i=-3; i<=3; i++)
		n+=c(i);
	return n;
}
