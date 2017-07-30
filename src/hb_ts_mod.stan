data {
	int<lower=0> N;
	real<lower=0> x1[N];
	real<lower=0> x2[N];
	real<lower=0> x3[N];
	real<lower=0> y[N];
}

parameters {
	real trend[N];
	real s_trend;
	real s_q;
	real<lower=0> a;
	real<lower=0> b;
	real<lower=0> c;
	real d;
}

model {
	real q[N];
	real cum_trend[N];
	for (i in 3:N)
		trend[i]~normal(2*trend[i-1]-trend[i-2],s_trend);

	cum_trend[1]=trend[1];
	for (i in 2:N)
		cum_trend[i]=cum_trend[i-1]+trend[i];

	for (i in 1:N)
		q[i]=y[i]-cum_trend[i];
	for (i in 1:N)
		q[i]~normal(a*x1[i]+b*x2[i]+c*x3[i]+d,s_q);
}