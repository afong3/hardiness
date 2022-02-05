// writing stan models is for another time. Let's just get this thing running 

// Intercept only model

data {
	int<lower=1> N;
    vector[N] x;        // x vector
	vector[N] y; 		// response
	}

parameters {
  //real mu_a;   
  //real<lower=0> sigma_a;
  real<lower=0> sigma_y; 
  real a; // intercept

  real<lower=0> b; // slope
  real<lower=0> sigma_b;
	}

transformed parameters {
  real yhat[N];
  for(i in 1:N){
      yhat[i] = a + b*x[i];
    }
	}

model {
  a ~ normal(0, 3);
  sigma_y ~ normal(2, 2);
  y ~ normal(yhat, sigma_y);
}
