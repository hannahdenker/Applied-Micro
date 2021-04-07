<<dd_remove>>

*Anything in between the dd_remove bits will be a comment that won't show
*up in the Markdown document
**************************************************************************
*
*   PROGRAM: 	PSET 7
*   AUTHOR: 	Hannah Denker 
*	PURPOSE: 	Documenting work for PSET 7
*	CREATED: 	04/05/21
*	UPDATED:  		
*	TEAMMATES:	Michelle Doughty	
*	CALLS UPON:	
*	PRODUCES:	Figures: 	Yes 
*				Datasets:	Yes	
*				Tables:		No	
*
*	CONTENTS:	0. Set pathways, log, globals
*				1. Open data and Prepare for Analysis
*				2. Preliminary Analysis
*				3. Main Analysis
*
*
**************************************************************************
<</dd_remove>>

<<dd_remove>>
<<dd_do>>	
	clear all
	set more off
	pause on
	*set memory 500m, perm // ignored in Stata. See Stata result window. 

	***Set cd for header.txt file to run & opens the folder in Git for this
	***PSET
	cd "/Users/hannahdenker/Documents/GitHub/Applied-Micro/docs/ps7/"

	* dyndoc "ps7_denker.txt", replace
	
	glob projectpath	"/Users/hannahdenker/Google Drive/Coursework/Yr4: Spring 2021/MicroEcon/"
	glob datapath 		"${projectpath}5. Datasets/"
	glob gendatapath 	"${projectpath}7. Generated Datasets/"

<</dd_do>>
<</dd_remove>>

<<dd_remove>>
*******************************
*
*	0. Markdown Settings
*
*******************************
<</dd_remove>>
<<dd_version: 1>>
<<dd_include: header.txt>>


# Problem Set 7
Course: ECON 8848  
Author: Hannah Denker  
Collaborators: Michelle Doughty 
Date: <<dd_display: c(current_date)>>  

<nav id="toc"><strong><font size="5">Table of Contents</font></strong></nav>


<<dd_remove>>
*******************************
*
*	1. Open data and Prepare for Analysis
*
*******************************
<</dd_remove>>

## Open data and Prepare for Analysis
<<dd_do>>
	use "${datapath}psidextract.dta", clear
<</dd_do>>

### Sample Selection and Reshaping

**How are the data stored, long or wide? Which years do you have in your sample?**  
<<dd_do>>	
	describe
<</dd_do>>
The data in this sample are wide. We can tell because the variables all have year suffixes in the variable names. We have 1997, 1999, and 2001 in this sample.  

Limit your sample to individuals who are between the ages of 18 and 55 in 1997.  
<<dd_do>>	
	drop if age1997<18
	drop if age1997>55	
<</dd_do>>


Get the data into “long” format using the reshape command. Note that the education variable is measured only once, and therefore does not need to be reshaped.  
<<dd_do>>	
	reshape long age marst work union salary wage tenure weight heightft heightin , i(id) j(year)
<</dd_do>>

### Cleaning and Recoding

A value of 1 in the “marst” variable means that the observation is married. Create a “married” dummy that is 1 if the person is married and 0 otherwise.
<<dd_do>>	
	cap drop married
	generate married= . 
	replace  married= 1 if marst==1
	replace  married= 0 if marst!=1 & marst!=. 
	lab var  married "Marriage Dummy: 1=Married, 0=Not Married"
	* married marst, mi
<</dd_do>>

Workers in the sample are either paid by the hour or they are salaried. We need a new variable that measures hourly wages in a consistent way for all of our observations. Follow the list of steps below to do so:
– Start by creating a variable that is missing for everyone called “hourwage”  
– Replace it with the value of “wage” if that “wage” variable is a valid hourly wage (> 1 and < 100).   
– Replace it with the hourly version of the person’s annual salary as long as the “salary” variable implies an hourly wage between one dollar and 100 dollars.   
- Create a logwage variable that is the natural log of the “hourwage” variable you created.

Other cleaning steps: 
- Fix the coding on education. “99” means missing.
- Fix the coding on the union variable. In the current coding scheme 0, 8 and 9 mean missing, 1 means yes, and 5 means no. Create a normal 0/1 dummy variable where 1 means yes and 0 means no. Code the missing values correctly.
- Fix the coding on tenure. Valid responses begin at 1 and are measured in years of work experience. Other values (incl. 0, 98 and 99) indicate non-valid responses.
- The person’s height is coded in two variables, one measuring the feet component, and the other measuring the inches piece. Create a new variable called “heightinches” that is the person’s total height in inches. Recode any resulting values above seven feet tall as missing.
- Codes for weight above 900 pounds indicate missing. Recode these as appropriate.
- Drop any observations that have missing values for any of the following variables: logwage, married, education, age, union, and tenure. NOTE: Do not skip this step. If you do, you will have trouble with the rest of the problem set, given how STATA treats missing values.

<<dd_do>>	
	***Create hourwage var
	cap drop hourwage
	generate hourwage= . 
	replace  hourwage= wage if wage>1 & wage<100
	replace  hourwage= salary/2000 if inrange(salary, 2000, 200000)
	lab var  hourwage "Hourly version of the person’s annual salary"
	
	***Create Logwage var
	cap drop logwage 
	generate logwage= .
	replace  logwage= log(hourwage)
	lab var  logwage "Natural Log of Hour Wage var."

	***Edit Education var missings
	replace education=. if education==99
	*tab education, mi 

	***Edit Union variable
	replace union = . if union == 0 | union == 8 | union == 9
	replace union = 0 if union == 5
	replace union = 1 if union == 1
	lab var union "Union Dummy: 1=In Union, 0=Not in Union"

	***Fix coding on "tenure" var
	replace tenure=. if tenure==0 | tenure==98 | tenure==99

	***Create new height var where height is measured in inches
	cap drop heightinches
	generate heightinches= heightft*12 + heightin
	replace  heightinches= . if heightinches > 7*12
	drop heightft heightin

	***Fix weight var
	replace weight= . if weight>900

	***Drop obs that have missing values for covariates
	drop if missing(logwage) | missing(married) | missing(education) | missing(age) | missing(union) | missing(tenure)

<</dd_do>>

Finally, xtset the data, using a delta of 2 so that l.var means the measure from the previous wave, not from the previous year (which would always be missing).
<<dd_do>>
	xtset id year , delta(2)
<</dd_do>>


### Pooled OLS Regressions

For each of these regressions, use all available years and just ignore the panel component. If you know what clustering is, and you would like to use it to account for the non-independence of observations at the person-level, you are welcome to.

• Run a regression of logwage on the married dummy. Include dummies for two of the three waves as controls.
<<dd_do>>
	reg logwage married i.year, vce(cluster id) 
	dis (exp(_b[married]))-1 // interpreting coefficient since dummy
<</dd_do>>

You did not adjust the wage variables for inﬂation. Is this a problem? Why or why not?   
We do not need to adjust for inflation since we are controlling for year in our regression. 

Interpret the Results.   
Since we are interpreting the changes in a logged dependent variable using a binary independent variable, we want to exponentiate the coefficient - exp(.3358982)-1.  We see that on average across the years in our sample, married people have about a 40% higher hourly wage relative to unmarried peers. We can reject the null hypothesis that we would observe a value this large or larger by chance at p < 0.001. Additionally, we see that the average log wage for unmarried people is about 2.43 (or about $ 11.30 per hour).

Add education, age, union status, and tenure to the regression.
<<dd_do>>
	reg logwage married education age union tenure i.year, vce(cluster id)
	dis (exp(_b[married]))-1 // interpreting coefficient since dummy
<</dd_do>>

How do the results change?
The magnitude of the coefficient of interest decreased after adding this set of covariates. We see that on average across the years in our sample, married people have about a 29% higher hourly wage relative to unmarried peers while controlling for education, age, union statust, and tenure. We can reject the null hypothesis that we would observe a value this large or larger by chance at p < 0.001. It does not make much practical sense to interpret the constant after adding this set of controls. 

Now add the heightinches and weight variables as additional controls.
<<dd_do>>
	reg logwage married education age union tenure heightinches weight i.year, vce(cluster id) 
	dis (exp(_b[married]))-1 // interpreting coefficient since dummy
<</dd_do>>

What happened with your regression? Why? Hint: Look at your number of observations.
The sample size used in this analysis decreased by about 2,300 observations (from 6,792 to 4,467). This is probably because we did not drop observations with missingness in these two new controls like we did with the other control variables in our analysis. Additionally, we also see a that the coefficient on the variable of interest (married) decreased in magnitude again (by about 5 percentage points). 

Why might omitting these last two variables cause the CIA for this regression model to fail. Be speciﬁc.   
We might hypothesize that tall/muscular men are found to be more desired for marriage and more attractive to employers. Therefore, physical size would be correlated with both marriage and wages and leaving out these characteristics would bias our results. 


### FE Regressions 
#### Using "xtreg"

Run a FE regression of logwage on the married dummy. Include dummy variables for two of the three waves of the survey.
<<dd_do>>
	xtreg logwage married i.year,  fe
	dis (exp(_b[married]))-1 // interpreting coefficient since dummy
<</dd_do>>

Suppose that you tried to interpret this regression as the causal eﬀect of marriage on earnings. What have you assumed? How is this similar to and diﬀerent from the assumption you would need to interpret the married coeﬃcient as causal in the last cross-sectional regression you ran?   
If we interpret this regression as the causal effect of marriage on earnings, we have to assume that the variation in the diﬀerences-in-means, or in the “within” year estimator, is as-good-as-random. This is different from the assumption in the cross-sectional regression in that we assume that conditional on the set of chosen covariates, our treatment status is independent of both potential outcomes. In other words, we assume that after we have controlled for a group of observed characteristics, treatment status is uncorrelated with the two potential outcomes. 

Try to add controls for education, age, union status, and tenure.
<<dd_do>>
	xtreg logwage married i.year education age union tenure,  fe
	dis (exp(_b[married]))-1 // interpreting coefficient since dummy
<</dd_do>>
Which variable(s) did STATA drop? Explain why this makes sense.  
Stata dropped the "education" variable. This makes sense given that we would not expect variation within an individual's education after they start working. 


Is there a variable you expected to have dropped that was not? If so, which one? Explore the coding of any variables to see why they were not mechanically removed from the regression speciﬁcation.   
I think I was a little bit surprised that "union" was not dropped because I would have thought that there would not be much variation in an individual's union status over the course of 5 years, but I can see that within an individual over this time they are either joining or leaving a union, which might happen because of changes in their employer. 

<<dd_do>>
	***Look at variation in 
	sort id year 
	list id year education union in 1/10

	graph twoway (scatter tenure education if year==1997, mcolor(erose)) ///
				 (scatter tenure education if year==1999, mcolor(emidblue)) ///
				 (scatter tenure education if year==2001, mcolor(eltgreen)) ///
				 , ///
				 legend(rows(1) label(1 "1997") label(2 "1999") label(3 "2001")) ///
				 name(tenureXedu, replace)

	graph twoway (scatter age education if year==1997, mcolor(erose)) ///
			 	 (scatter age education if year==1999, mcolor(emidblue)) ///
			 	 (scatter age education if year==2001, mcolor(eltgreen)) ///
				 , ///
			 	 legend(rows(1) label(1 "1997") label(2 "1999") label(3 "2001")) ///
			 	 name(ageXedu, replace)			 
<</dd_do>>

What happened to the coeﬃcient on the married dummy when you moved from OLS to FE? Explain possible ways to interpret this change.   
The coefficient on marriage decreased substantially from OLS to FE. This happened because we are now comparing wages between two groups (married and unmarried men) to comparing wages within a person before and then after they get married. We see that in the FE regression, the coefficient on "married" is not statisically different from zero which suggests that there is not a causal relationship between being married and wages. 

What happened to the standard errors? Explain why this happened.



#### Using Dummy Variables for each <<dd_display: \alpha_i>>

Try to run your last regression by manually including a dummy variable for each value of ID. You may choose whether to omit one dummy or to omit a constant term, but you must do one or the other. NOTE: You can omit this actual regression from your do-ﬁle when you create your log.

What happens? Explain how STATA can run the “xtreg” regressions without encountering the same problem.

#### De-meaning
Run your last regression by ﬁrst manually creating new variables representing a “deviationin-means” for the dependent variable and each of the controls. Then run OLS on the “de-meaned” data. Feel free to omit the constant term since it will be zero if you include it, by construction.

Were you able to replicate the coeﬃcient results from “xtreg”? What about the standard errors?

#### Diﬀerencing as an Alternative 

Now run a First Diﬀerences speciﬁcation like the last FE regression you ran. Note:

you will need to create the diﬀerences yourself, taking advantage of the fact that your data are “xtset”

Ignoring diﬀerences in eﬃciency, which speciﬁcation do you prefer, FE or FD. Why?

Now run an FE and an FD regression, but limit the data to 1999 and 2001. IMPORTANT: Your FD regression should only include one diﬀerence for each individual. In other words, you should treat the diﬀerenced variables in 1999 as missing.

Do you get the same results in both models? If not, why not?








