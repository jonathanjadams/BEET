# BEET

<!-- Here: describe in General -->

The Behavioral Expectations Equilibrium Toolkit (BEET) is a toolkit for solving stochastic dynamic macroeconomic models with behavioral expectations in MATLAB.  BEET itself is not a model-solver; for that task, it uses existing methods.  Rather, BEET is a wrapper that transforms a behavioral expectations model into one that can be solved using tools designed for rational expectations.

*This toolkit is still extremely early!  USE AT YOUR OWN RISK!! (and please reach out to me when things go wrong!)*

 # Dependencies
 
 You will need either the [Uhlig Toolkit](https://home.uchicago.edu/~huhlig/js/Toolkit_4.3.zip "Uhlig") (*default method*) or  [Chris Sims' GENSYS](http://sims.princeton.edu/yftp/gensys/ "GENSYS") (*still experimental*).  You will also need MATLAB.  (MATLAB alternatives may be acceptable, but there are no guarantees that the toolkit will work.  Of course, that is true for MATLAB as well...).  Main functionality was confirmed on MATLAB R2019a.

 # File Descriptions

- **BEET documentation.pdf** contains the conceptual documentation for the BEET toolkit *START HERE*

- **BEET_solve.m** solves the policy function for a behavioral model, using the **Uhlig Toolkit**.  The inputs are:
  - **AA_fire**, **BB_fire**,... **NN_fire** (*Required*): matrices which encode the rational expectations model in "Uhlig form" (corresponding to matrices $A,B,...N$ respectively in Uhlig's notation)
  - **BEET_method**: scalar identifying which method should be used to solve the model.  $0$ indicates Uhlig, $1$ indicates GENSYS (*still experimental*), $2$ indicates both (default: $0$)
  - **BE_phivec**: vector of coefficients $[\phi_0,\phi_1,...,\phi_J]$ that encode a subrational behavioral expectations operator $\mathbb{E}^k$ in terms of current and past rational forecasts:
    $$\mathbb{E}^k_t[x_{t+1}] = \sum_{j=0}^{J}\phi_j \mathbb{E}_{t-j}[x_{t+1}]$$
  - **senti_exovars**: vector of indices identifying any exogenous variables about which agents have stochastic belief distortions or "sentiments"
  - **senti_endovars**: vector of indices identifying any endogenous variables about which agents have stochastic belief distortions or "sentiments"
  - **fcast_vars**: vector of indices identifying any endogenous variables whose one-period-ahead forecasts should be added to the model as additional endogenous variables.  This will be done automatically for variables identified in **senti_endovars**, even if they are not specified here.
  - **fcast_hors**: matrix identifying any variables whose many-periods-ahead forecasts should be added to the model as additional endogenous variables.  If there are $n$ such forecasts to be added, **fcast_hors** is specified as an $n\times 3$ matrix.  In each row, the first entry indexes the endogenous variable to be forecast, the second entry indexes the forecast horizon (an integer number of periods), and the third entry is set to $1$ if the forecast is cumulative and $0$ otherwise.

- **BEET_irfs.m** calculates and plots impulse response functions to exogenous shocks.  The inputs are:
  - **irf_T**: scalar setting the IRF horizon to calculate  (default: $12$)
  - **BEET_irf_plot**: scalar which triggers plots of the IRFs, if set to $1$ (default: $1$)
  - **BEET_irf_vars**: vector identifying which exogenous states to calculate IRFs for (default: all)
  - **plot_z_irfs**: scalar which triggers inclusion of IRFs to exogenous states when IRFs are plotted, if set to $1$ (default: $1$)
  - **xtitles**, **ytitles**, **ztitles**: cell arrays containing labels (as strings) of the $x$, $y$, and/or $z$ variables (optional)

- **BEET_sim.m** simulates a model solved with **BEET_solve.m**

- **BEET_foreterm.m** calculates the term structure of forecasts for a model solved with **BEET_solve.m**


# To Do

- Resolve GENSYS-Uhlig inconsistenies

- Add functionality for non diagonal BEs with arbitrary coefficients on lags

- Sunspots


 
