library(quantmod)
library(rstan)
SPY <- getSymbols("SPY", auto.assign=FALSE)
barChart(SPY, theme='white.mono',bar.type='hlc',subset='2017-03::2017')

R <- na.omit(ROC(Ad(SPY)))
SAMPLES <- stan("./src/sv.stan", data=list(y=as.vector(R), T=length(R)))
PP <- apply(exp(extract(SAMPLES, "h")[[1]]/2), 2,
            quantile, c(0.05, 0.50, 0.95))


#####################################################################
library(rstan)
library(shinystan)
library(quantmod)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Get data from FRED
#####################################################################
getSymbols("GDPC1", src="FRED")

dat = list(y = as.vector(coredata(log(GDPC1))), N = dim(GDPC1)[1],
           signal_noise_prior_mean = 100, signal_noise_prior_std = 200,
           sigma_epsilon_prior_mean = 1, sigma_epsilon_prior_std = 2,
           cycle_trend_prior_mean = 0.5, cycle_trend_prior_std = 1,
           rho_alpha = 0, rho_beta = 1, lambda_alpha = 4, lambda_beta = 9);

# Fit
#####################################################################
fit = stan(file="./src/ts_trend_cycle.stan", data=dat,
           control=list(max_treedepth=15, adapt_delta=0.95),
           iter=2000, chains=4)

pairs(fit, pars=list("sigma_zeta", "sigma_epsilon", "sigma_kappa",
                     "lambda", "rho", "mu_0_offset"))

launch_shinystan(drop_parameters(as.shinystan(fit), pars=c("beta", "mu", "psi")))
