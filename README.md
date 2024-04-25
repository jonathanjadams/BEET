# BEET

<!-- Here: describe in General -->

The Behavioral Expectations Equilibrium Toolkit (BEET) is a toolkit for solving stochastic dynamic macroeconomic models with behavioral expectations in MATLAB.  BEET itself is not a model-solver; for that task, it uses existing methods.  Rather, BEET is a wrapper that transforms a behavioral expectations model into one that can be solved using tools designed for rational expectations.

 # Dependencies
 
 You will need either the Uhlig Toolkit or Chris Sims' GENSYS.  You will also need MATLAB.  (MATLAB alternatives may be acceptable, but there are no guarantees that the toolkit will work.  Of, that is true for MATLAB as well...)

 # File Descriptions

- BEET documentation.pdf contains the documentation for the BEET toolkit *START HERE*

- BEET_solve.m solves the policy function for a behavioral model

- BEET_irfs.m calculates and plots impulse response functions to exogenous shocks

- BEET_sim.m simulates the model

- BEET_foreterm.m: this program calculates the term structure of forecasts for a model solved with BEET_solve.m



 
