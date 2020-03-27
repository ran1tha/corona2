# Roles played by quarantining, social distancing and suspect testing in shaping the future of COVID-19 outbreak in Sri Lanka. 

[Matlab r2020] <br>
Published on: 28/03/2020


This repository is based on an extension of the model developed [here](github.com/ran1tha/corona). <br>

To get a basic idea of how epidemiological models are designed, I strongly suggest you refer to [my previous repository](github.com/ran1tha/corona). The model which is discussed there is designed with fewer parameters and states and hence less complicated.<br>

The content discussed here is at large dependent on the information found on [paper 1](https://www.ijidonline.com/article/S1201-9712(20)30137-5/fulltext) and [paper 2](https://www.researchgate.net/publication/338857202_Estimation_of_the_Transmission_Risk_of_the_2019-nCov_and_Its_Implication_for_Public_Health_Interventions). <br>

To skip all the technicalities and go directly to the predictions [click here!](#pred "Goto Predictions").


##

**DISCLAIMER**

* **Data considered here is recorded starting from 15th March 2020. [This is when WHO recognized Sri Lanka as a country that spreads COVID-19 via Local Transmission.](https://www.who.int/docs/default-source/coronaviruse/situation-reports/20200315-sitrep-55-covid-19.pdf?sfvrsn=33daa5cb_8)** <br>

* **Primary data source is [The Epidemiological Unit, Ministry of Health, Sri Lanka.](epid.gov.lk)** 

* **The number of Quarantined people discussed here are the ones housed at quarantine centres. Home-quarantined individuals are regarded as part of the wider (susceptible) community. The quarantined individuals are calculated based on the data found [here.](http://www.epid.gov.lk/web/images/pdf/Circulars/Corona_virus/covid-19%20exposure%20history.pdf) It is assumed that the exposed individuals are all taken into quarantine centres to be quarantined almost instantaneously.**

* **If someone can assist me in finding reliable data regarding the number of quarantined people please contact me at ranitha@ieee.org. A more reliable prediction can be made then.**

* **Initial guesses for all the parameters were made by averaging the parameters of China when the situation in China showed a similar behaviour like ours. Data taken from [paper 1.](https://www.ijidonline.com/article/S1201-9712(20)30137-5/fulltext)**

* **The content of this repository may only be used for educational purposes. The author (Ranitha Mataraarachchi) does not take any responsibility for circumstances caused by the misinterpretation of what is stated in this repository.**

## The Model

This model is a modified SIR epidemiological model. To understand how SIR models work [read this.](github.com/ran1tha/corona) <br>

Modifications are done to include quarantined individuals, suspected cases and unidentified infectives which basic SIR models fail to include. <br>

To understand better, here is the model we are going to consider.

![](images/model.png)

<br>

The total population is grouped into 6 classes. 

* S - The susceptible population. This is the population which is vulnerable to the infection.

* E - The exposed population. People those who have been exposed to the infection by coming into contact with an infective person.

* I - The active unidentified infective population. People who are infected by the disease but have not yet been identified. This group of people are responsible for the spreading of the disease.

* R - Recovered people from the infection.

* Sq - Susceptible quarantined population. People who are quarantined in quarantine centres.

* B - The suspected class. People who have shown the symptoms of the disease and are suspected to have COVID-19.

* H - Active confirmed infectives. Infectives who are identified to be positive for COVID-19.


Here is how it works, <br>

Suppose the contact rate between individuals is ***c.*** Then the rate of contact between Susceptible population and Unidentified Infective population also becomes ***c.*** Now, by imposing contact tracing a proportion ***q*** of the contacted individuals move to the Suspected class(if effectively infected) or to the Susceptible Quarantined class (if not effectively infected). The probability that the disease is transmitted (probability of being effectively infected) given that a Susceptible person and Infective has come into contact is given by ***beta.*** The proportion of the population who has missed being quarantined, ***(1-q),*** move into the Exposed class on being effectively infected or remain in the Susceptible class if not. <br>

Now, the rate at which quarantined individuals move into the Susceptible Quarantined class is ***(1-beta) * c * q.*** <br>
The rate at which quarantined individuals move into the Suspected class is ***beta * c * q.*** <br>
The rate at which the people who are not quarantined move into the Exposed class is ***beta * c * (1-q).*** <br>

Let constant ***m*** be the transition rate from Susceptible class to the Suspected class via general clinical examinations due to fever or illness-like symptoms. 

COVID-19 detection tests are performed on the Suspected class at a rate of ***b.*** The probability such a test yields a positive result is given by ***f.*** Therefore, the rate of people leaving the Suspected class on being subjected to a detection test is ***b.*** The rate at which people move into the Active confirmed infectives class is ***bf.*** And the rate at which people are released back into society on being tested negative is ***b(1-f).***

The transition rate of Exposed individuals into the Unidentified infectives class is ***sigma.*** And the rate at which Susceptible quarantined individuals are sent back into the wider community is ***lambda.*** <br>

Unidentified active infectives are identified to be infectives at a rate of ***delta.*** Also, the rate of recovery is set to be ***gamma*** and the rate of mortality is ***alpha.***

Now the information above can be summarized into a set of simultaneous nonlinear ordinary differential equations as below,

![](images/equation.png) <br>

The data available are,

* Daily confirmed infective population (H)

* Daily recovered population (R)

* Daily suspected population (B)

* Daily quarantined susceptible population (Sq)

The goal is to identify each parameter of these equations that best match the available data. Additionally, the initial Unidentified infectives and the initial Exposed population are also unknown.

## Markov Chain Monte Carlo (MCMC) method and Model fitting

To fit the data into the model and to get the values of unknown parameters Markov Chain Monte Carlo method was used. <br>

A Zero-Math Introduction to Markov Chain Monte Carlo Methods can be found [here.](https://towardsdatascience.com/a-zero-math-introduction-to-markov-chain-monte-carlo-methods-dcba889e0c50)

The git repo for MCMC Matlab toolbox can be accessed and freely downloaded from [here](https://github.com/mjlaine/mcmcstat) and it includes a variety of examples to be referred to.

***The Matlab code used by me is included in this repository.***

Following are the specifications for the Markov Chain Monte Carlo method used by me,

* An adaptive Metropolis-Hastings (M‐H) algorithm was adopted to carry out the MCMC procedure

* The algorithm is run for 600,000 iterations with a burn‐in of the first 100,000 iterations

* The Geweke convergence diagnostic method is employed to assess convergence of chains

### Parameter and Initial condition estimations by MCMC method

| Parameter /Initial Value | Definitions                                   | Estimation | Std   | Source                |
|--------------------------|-----------------------------------------------|------------|-------|-----------------------|
| ***c***                  | contact rate                                  |            |       | MCMC                  |
| ***beta***               | probability of transmission                   | cc         |       | MCMC                  |
| ***q***                  | quarantined proportion                        |            | sdsds | MCMC                  |
| ***m***                  | rate of transition from ***S*** to ***B***    |            |       | MCMC                  |
| ***b***                  | rate of detection                             |            |       | MCMC                  |
| ***f***                  | test positive probability                     |            |       | MCMC                  |
| ***delta***              | rate of transition from ***I*** to ***H***    |            |       | MCMC                  |
| ***gamma***              | rate of recovery                              |            |       | MCMC                  |
| ***alpha***              | mortiality rate                               |            |       | MCMC                  |
| ***sigma***              | transition rate from ***E*** to ***I***       |            |       | WHO                   |
| ***lambda***             | rate at which quarantined people are released |            |       | Incubation Period     |
| ***H(0)***               | Initial confirmed active infectives           |            |       | [source](epid.gov.lk) |
| ***B(0)***               | Initial suspected people                      |            |       | [source](epid.gov.lk) |
| ***R(0)***               | Initial recovered people                      |            |       | [source](epid.gov.lk) |
| ***Sq(0)***              | Initial susceptible quarantined people        |            |       | [source](epid.gov.lk) |
| ***S(0)***               | Initial susceptibles (Population of SL)       |            |       | UN Data               |
| ***E(0)***               | Initial exposed people                        |            |       | MCMC                  |
| ***I(0)***               | Initial unidentified active infectives        |            |       | MCMC                  |

<br>

Here are the probability density functions of all the parameters / initial values derrived by MCMC 

![](images/params.png)
<br>

## <a name="pred"></a> Predictions

As of today (27th Marth 2020), there are,

* 99 confirmed active cases.

* 7 recovered patients

* 237 suspected cases

* 3549 people in quarantine centres

### By the model derived earlier, here are the predictions for the next 50 days.

![](images/HIRplot.png) <br>

### Forecast for the next 50 days with a 95% confidence interval. 

The black lines indicate the best fitting curve while the grey area indicates the 95% confidence interval based on the available data. Actual data is also plotted (circles) for comparison.

**Confirmed Active cases. *H(t)***
![](images/) <br>

**Recovered cases cases. *R(t)***
![](images/) <br>

**Unidentified Active cases. *H(t)***
![](images/) <br>

**Suspected Cases cases. *B(t)***
![](images/) <br>

**Quarantined people. *H(t)***
![](images/) <br>

### How do the changes in parameters affect the forecast?

**Changing the contact rate**

Contact rate is the average number of people a single person comes into contact within a day.
At present, the estimated contact rate is xxxx. Here are the forecasts for the next 50 days when the contact rate is doubled and halved.
![](images/c.png) <br>

**Changing the quarantined proportion**

Quarantined proportion is the proportion of people quarantined given that they were exposed to an infected person.
At present, the estimated quarantined proportion is xxxx. Here are the forecasts for the next 50 days when the quarantined proportion is doubled and halved.
![](images/q.png) <br>

**Changing the detection rate and recovery rate**

Detection rate is the rate at which suspected individuals are tested for COVID-19.
The recovery rate is the rate at which patients recover.
At present, the estimated detection rate is xxxx and the estimated recovery rate is xxxxx. Here are the forecasts for the next 50 days when the detection rate and the recovery rate are doubled. 
![](images/bgamma.png) <br>

**Which is the most important parameter that needs to be changed?**

Given here are the forecasts for the next 50 days where,

* Contact rate is halved

* Quarantined proportion is doubled

* Detection rate is doubled

* Recovery rate is doubled

![](images/best.png) <br>


## References

[1] : The effectiveness of quarantine and isolation determine the trend of the COVID-19 epidemics in the final phase of the current outbreak in China <br>
        https://www.ijidonline.com/article/S1201-9712(20)30137-5/fulltext
       
[2] : Estimation of the Transmission Risk of the 2019‐nCoV and Its Implication for Public Health Interventions  <br>
        https://www.researchgate.net/publication/338857202_Estimation_of_the_Transmission_Risk_of_the_2019-nCov_and_Its_Implication_for_Public_Health_Interventions
        
[3] : MCMC toolbox for Matlab <br>
        https://mjlaine.github.io/mcmcstat/
        

<br/>
<br/>
<br/>
<br/>

Ranitha Mataraarachchi, <br/>
Room No: 2234, <br/>
Akbar-Nell Hall, <br/>
Faculty of Engineering, <br/>
University of Peradeniya, <br/>
Peradeniya, Sri Lanka.

(+94)777722662 </br>
ranitha@ieee.org <br/>
[Facebook](https://www.facebook.com/1994ranitha) | [LinkedIn](https://www.linkedin.com/in/ranitha/)
