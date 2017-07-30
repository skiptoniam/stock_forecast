data {
  int<lower=0> N;
  real y[N];
  
  // Priors on variances
  real <lower=0> sigma_epsilon_prior_mean;
  real <lower=0> sigma_epsilon_prior_std;
  real <lower=0> signal_noise_prior_mean;
  real <lower=0> signal_noise_prior_std;
  real <lower=0> cycle_trend_prior_mean;
  real <lower=0> cycle_trend_prior_std;
  
  // Priors on cycle process
  real rho_alpha;
  real rho_beta;
  real <lower=0> lambda_alpha;
  real <lower=0> lambda_beta;
}

parameters {
  // Variances
  real <lower=0> sigma_epsilon;
  real <lower=0> ratio_signal_noise;
  real <lower=0> ratio_cycle_trend;
  
  // Cycle process
  real <lower=0, upper=1> lambda;
  real <lower=0, upper=1> rho;
  
  // Time series of trend and cycle
  vector[N] beta;
  matrix[N, 2] psi;
  
  // Initial value of trend (diffuse / no likelihood)
  real mu_0_offset;
}

transformed parameters{
  real <lower=0> sigma_zeta;
  real <lower=0> sigma_kappa;
  matrix[2,2] T_psi;
  vector[N] mu;
  real mu_0;
  
  // Cycle transition equation
  T_psi[1,1] = rho * cos(lambda);
  T_psi[2,1] = -rho * sin(lambda);
  T_psi[1,2] = rho * sin(lambda);
  T_psi[2,2] = rho * cos(lambda);
  
  // Defined ratio_signal_noise = sigma_eta / sigma_epsilon
  sigma_zeta = sigma_epsilon * ratio_signal_noise;
  // Defined ratio_cycle_trend = sigma_kappa / sigma_eta
  sigma_kappa = sigma_zeta * ratio_cycle_trend;
  
  // Trend defined from slope
  // Fix scale of mu_0:
  mu_0 = mu_0_offset + y[1];
  mu = cumulative_sum(beta) + mu_0;
}

model {
  // Priors
  sigma_epsilon ~ normal(sigma_epsilon_prior_mean, sigma_epsilon_prior_std);
  ratio_signal_noise ~ normal(signal_noise_prior_mean, signal_noise_prior_std);
  ratio_cycle_trend ~ normal(cycle_trend_prior_mean, cycle_trend_prior_std);
  rho ~ uniform(rho_alpha, rho_beta);
  lambda ~ beta(lambda_alpha, lambda_beta);
  
  // Build trend
  // Beta nonstationary, ignore any "error" in the first period.
  beta[2:N] ~ normal(beta[1:N-1], sigma_zeta);
  
  // Build cycle
  // First period psi variance depends on inverted system since we have a max
  // eignevalue less than one here.
  psi[1] ~ normal(0, (1 / (1-rho^2)) * sigma_kappa);
  // Project psi forward each period
  for (i in 2:N) {
    psi[i] ~ normal(T_psi * psi[i-1]', sigma_kappa);
  }

  // Likelihood of data
  y ~ normal(mu + psi[,1], sigma_epsilon);
}
