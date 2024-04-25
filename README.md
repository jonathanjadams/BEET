# BEET

<!-- Here: describe in General -->

The Behavioral Expectations Equilibrium Toolkit (BEET) is a toolkit for solving stochastic dynamic macroeconomic models with behavioral expectations in MATLAB.  BEET itself is not a model-solver; for that task, it uses existing methods.  Rather, BEET is a wrapper that transforms a behavioral expectations model into one that can be solved using tools designed for rational expectations.

 # Dependencies
 
 You will need either the Uhlig Toolkit or Chris Sims' GENSYS.  You will also need MATLAB.  (MATLAB alternatives may be acceptable, but there are no guarantees that the toolkit will work.  Of, that is true for MATLAB as well...).  Main funcitonality was confirmed on MATLAB R2019a.

 # File Descriptions

- **BEET documentation.pdf** contains the conceptual documentation for the BEET toolkit *START HERE*

- **BEET_solve.m** solves the policy function for a behavioral model.  The inputs are:
  - (_Required_) Matrices **AA_fire**, **BB_fire**,... **NN_fire** which encode the rational expectations model in "Uhlig form"
  - **BE_phivec** a vector of coefficients $[\phi_0,\phi_1,...,\phi_J]$ that encode a deterministic behaiovral expectations operator $\mathbb{E}^k$ in terms of current and past rational forecasts:
    $$\mathbb{E}^k_t[x_{t+1}] = \sum_{j=0}^{J}\phi_j \mathbb{E}^k_{t-j}[x_{t+1}]$$
  - **senti_exovars** a vector of indices identifying the exogenous variables about which agents have stochastic belief distortions or "sentiments"
  - **senti_endovars** a vector of indices identifying the endogenous variables about which agents have stochastic belief distortions or "sentiments"
  - **fcast_vars** a vector of indices identifying the endogenous variables whose one-period-ahead forecasts should be added to the model as additional endogenous variables.  This will be done automatically for variables identified in **senti_endovars**, even if they are not specified here.
  - **fcast_hors** indentifies variables whose many-periods-ahead forecasts should be added to the model as additional endogenous variables.  If there are $n$ such forecasts to be added, **fcast_hors** is specified as an $n\times 3$ matrix.  In each row, the first entry indexes the endogenous variable to be forecast, the second entry indexes the forecast horizon (an integer number of periods), and the third entry is set to $1$ if the forecast is cumulative and $0$ otherwise.

- **BEET_irfs.m** calculates and plots impulse response functions to exogenous shocks
  - **ztitles**
  - **xtitles**
  - **ytitles**

- **BEET_sim.m** simulates the model

- **BEET_foreterm.m** calculates the term structure of forecasts for a model solved with **BEET_solve.m**





 
