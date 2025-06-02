options ps=55 ls=175 validvarname=v7 dlcreatedir nodate nonumber;
*options mprint mlogic spool msglevel=i;
options fmtsearch=(work in1);

*******************************************************************;
*** 187_ODSOutput_Exercises		     			***;
*** Program Author: Louise Hadden                               ***;
*** Purpose: Demonstrate ODS Output Objects                     ***;
*** Input(s): SASHELP.HEART                                     ***;
*** Output(s): ODS OUTPUT					***;
*** Modifications: (date/initials/reason)                       ***;
*******************************************************************;

*******************************************************************;
***	Parameters:						***;
*******************************************************************;

ods noproctitle;

***>>STEP1: replace indir with the directory you are working in;
%let indir=C:\Users\Owner\OneDrive\Documents\SASConferences\PHARMASUG\PharmaSUG2025\Papers\187_ODSOutput;

libname in1 "&indir.";
libname out1 "&indir.";
filename odsout "&indir.";
run;

title1 "Paper 187: ODS Output";
footnote1 "Last Run &sysdate. &systime - By &sysuserid";
run;

*******************************************************************;
***	Create formats for revised HEART data set 		***;
*******************************************************************;
***>>STEP2: run PROC FORMAT and review FMTLIB output;
proc format library=work fmtlib;
	value bmi_catf	1 = 'Underweight (<18.5)'
			2 = 'Healthy Weight (<18.5-<25)'
			3 = 'Overweight (<25-<30)'
			4 = 'Obesity (30+)';

	value obesityf	1 = 'Not Obese'
			2 = 'Class 1 Obesity'
			3 = 'Class 2 Obesity'
			4 = 'Class 3 Obesity (Severe)';
run;
quit;

*******************************************************************;
***	Create revised HEART data set           		***;
*******************************************************************;
***>>STEP3: Create revised HEART data set;

*** subroutine - enhance the SASHELP.HEART data set;

data out1.heart (label="Enhanced version of SASHELP.HEART");
    set sashelp.heart;

*** create missing variable labels;
    label 	status="Status"
	      	sex="Sex"
		height="Height"
		weight="Weight"
		Diastolic="Diastolic Blood Pressure"
		Systolic="Systolic Blood Pressure"
		Smoking="Smoking Status"
		Cholesterol="Cholesterol Status";

*** create a faux group variable;
	HeartID=modz(_n_,4);

*** create a faux id;
	SeqNum=_n_;

*** create a faux weight;
	SampleWeight = 1 + (mod(_n_,10)*.1);

*** create BMI variables;
    bmi= weight / height**2 * 703;
	select;
		when (1 le bmi lt 18.5) bmi_cat = 1;
		when (18.5 le bmi lt 25) bmi_cat = 2;
		when (25 le bmi lt 30) bmi_cat = 3;
		when (30 le bmi) bmi_cat = 4;
		otherwise  bmi_cat = .;
	end;
	select;
		when (1 le bmi lt 30) obesity_cat = 1;
		when (30 le bmi lt 35) obesity_cat = 2;
		when (35 le bmi lt 40) obesity_cat = 3;
		when (40 le bmi) obesity_cat = 4;
		otherwise  obesity_cat = .;
	end;
	select;
	    when (sex='Female') female = 1;
		otherwise  female = 0;
	end;
	select;
	    when (sex='Male') male = 1;
		otherwise male = 0;
	end;


	label 	HeartID="Heart Group Variable"
	      	SeqNum="Sequence Number"
	      	bmi="BMI"
		bmi_cat="BMI Category"
		obesity_cat="Obesity Category"
		SampleWeight="Sample Weight"
		male="Binary: Male"
		female="Binary: Female";

run;

*******************************************************************;
***	PROC Contents Collate (Default)				***;
*******************************************************************;
***>>STEP4: Run Default PROC CONTENTS on revised HEART data set and examine results;
***>>NOTE: Default PROC CONTENTS presents variables sorted by alphabetic order;
***>>NOTE: This is also known as COLLATE;
***>>NOTE: Notice how many pieces the output is in; 

*** Default PROC CONTENTS;

proc contents data=out1.heart;
title2 "Contents of Heart - Collate";
run;

title2;
run;

*******************************************************************;
***	PROC Contents VARNUM					***;
*******************************************************************;
***>>STEP5: Run PROC CONTENTS VARNUM on revised HEART data set and examine results;
***>>NOTE: Default PROC CONTENTS presents variables sorted by position;
***>>NOTE: Position is the order the variables appear in the PDV (Program Data Vector);
***>>NOTE: Notice how the output differs from the COLLATE PROC CONTENTS; 

*** PROC CONTENTS VARNUM;

proc contents data=out1.heart varnum;
title2 "Contents of Heart - Varnum";
run;

title2;
run;

*******************************************************************;
***	PROC Contents Out=					***;
*******************************************************************;
***>>STEP6: Run PROC CONTENTS VARNUM on revised HEART data set and output out= data set;
***>>NOTE: What variables appear in the rectangular data base, and at what levels;
***>>NOTE: Do any / all of these variables appear in the listing contents;
***>>NOTE: Notice how the output differs from the COLLATE PROC CONTENTS; 
***>>STEP6A: Run a test print and a contents on the out= data set and examine;

*** PROC CONTENTS with OUTPUT data set;

proc contents data=out1.heart out=contents_out1_heart noprint;
title2 "Contents with OUT= data set";
run;

proc print data=contents_out1_heart (obs=5) noobs;
title2 "Test Print of OUT= data set";
run;

proc contents data=contents_out1_heart;
title2 "Contents of OUT= data set";
run;

title2;
run;

*******************************************************************;
***	Using ODS Trace												***;
*******************************************************************;
***>>STEP7: Run PROC CONTENTS ORDER=COLLATE on revised HEART data set and use ODS TRACE;
***>>NOTE: Review the log carefully for output data sets;
***>>NOTE: Review the files in the results window; 

*** PROC CONTENTS COLLATE with ODS TRACE data set;

ods trace on / listing;

proc contents data=out1.heart order=collate;
title2 "Contents of Heart - Order=Collate - ODS TRACE";
run;

ods trace off;

*******************************************************************;
***	Using ODS Trace												***;
*******************************************************************;
***>>STEP7: Run PROC CONTENTS ORDER=COLLATE on revised HEART data set and use ODS TRACE;
***>>NOTE: Review the log carefully for output data sets;
***>>NOTE: Review the files in the results window; 
*** PROC CONTENTS COLLATE with ODS TRACE data set;

ods trace on / listing;

proc contents data=out1.heart order=collate;
title2 "Contents of Heart - Order=Collate - ODS TRACE";
run;

ods trace off;

*******************************************************************;
***	Harvesting ODS Output Objects								***;
*******************************************************************;
***>>STEP8: Check the Trace Results in the Log and record the temporary data set names;
***>>STEP8: Write an ODS OUTPUT code sandwich to output to work files and close ODS Output;
***>>STEP8: PROC CONTENTS and test prints on each ODS output file; 


ods output attributes=attributes1 enginehost=enginehost1 variables=variables1;

proc contents data=out1.heart order=collate;
title2 "Collate contents with ODS OUTPUT objects";
run;

ods output close;

proc contents data=attributes1;
title2 "Contents of Attributes ODS Output (Collate)";
run;

proc print data=attributes1 (obs=5) noobs;
title2 "Test Print Attributes ODS Output (Collate)";
run;

proc contents data=enginehost1;
title2 "Contents of Engine Host ODS Output (Collate)";
run;

proc print data=enginehost1 (obs=5) noobs;
title2 "Test Print Engine Host ODS Output (Collate)";
run;

proc contents data=Variables1;
title2 "Contents of Variables ODS Output (Collate)";
run;

proc print data=Variables1 (obs=5) noobs;
title2 "Test Print Variables ODS Output (Collate)";
run;

*******************************************************************;
***	Using ODS Trace												***;
*******************************************************************;
***>>STEP9: Run PROC CONTENTS ORDER=VARNUM on revised HEART data set and use ODS TRACE;
***>>NOTE: Review the log carefully for output data sets;
***>>NOTE: Review the files in the results window; 
*** PROC CONTENTS VARNUM with ODS TRACE data set;

ods trace on / listing;

proc contents data=out1.heart order=varnum;
title2 "Contents of Heart - Order=VARNUM - ODS TRACE";
run;

ods trace off;

*******************************************************************;
***	Harvesting ODS Output Objects								***;
*******************************************************************;
***>>STEP10: Check the Trace Results in the Log and record the temporary data set names;
***>>STEP10: Write an ODS OUTPUT code sandwich to output to work files and close ODS Output;
***>>STEP10: PROC CONTENTS and test prints on each ODS output file; 



ods output attributes=attributes2 enginehost=enginehost2 position=position2;

proc contents data=sashelp.heart order=varnum;
title2 "Varnum contents with ODS OUTPUT objects";
run;

ods output close;

proc contents data=attributes2;
title2 "Contents of Attributes ODS Output (Varnum)";
run;

proc print data=attributes2 (obs=5) noobs;
title2 "Test Print Attributes ODS Output (Varnum)";
run;

proc contents data=enginehost2;
title2 "Contents of Engine Host ODS Output (Varnum)";
run;

proc print data=enginehost2 (obs=5) noobs;
title2 "Test Print Engine Host ODS Output (Varnum)";
run;

proc contents data=Position2;
title2 "Contents of Variables ODS Output (Varnum)";
run;

proc print data=Position2 (obs=5) noobs;
title2 "Test Print Variables ODS Output (Varnum)";
run;

*******************************************************************;
***	Create a sorted version of out1.heart						***;
*******************************************************************;
***>>STEP11: Create a sorted version of the out1.heart data set;

proc sort data=out1.heart out=out1.heart_sorted;
    by seqnum;
run;

*******************************************************************;
***	Using ODS Trace												***;
*******************************************************************;
***>>STEP12: Run PROC CONTENTS ORDER=VARNUM on sorted version of HEART data set and use ODS TRACE;
***>>NOTE: Review the log carefully for output data sets;
***>>NOTE: Review the files in the results window; 
*** PROC CONTENTS VARNUM with on sorted version of data set;

ods trace on;

proc contents data=out1.heart_sorted varnum;
title2 "Contents on Corrected Data Set - Sorted";
run;

ods trace off;

*******************************************************************;
***	Harvesting ODS Output Objects								***;
*******************************************************************;
***>>STEP13: Check the Trace Results in the Log and record the temporary data set names;
***>>STEP13: Write an ODS OUTPUT code sandwich to output to work files and close ODS Output;
***>>STEP13: PROC CONTENTS and test prints on each ODS output file; ;

ods output sortedby=sortedby;

proc contents data=out1.heart_sorted varnum;
title2 "Contents on Corrected Data Set - ODS Output Sorted By";
run;

ods output close;

ods trace off;

proc contents data=SortedBy;
title2 "Contents of SortedBY ODS Output Object";
run;

proc print data=SortedBY noobs;
title2 'Test Print of SortedBy ODS Output Object';
run;

title2;
run;

*******************************************************************;
***	Create an indexed version of out1.heart						***;
*******************************************************************;
***>>STEP14: Create a sorted version of the out1.heart data set;

data out1.heart_index;
    set out1.heart;
run;

proc datasets library=out1 nolist;
   modify heart_index;
      index create id=(seqnum heartid) / nomiss unique;
quit;

*******************************************************************;
***	Using ODS Trace												***;
*******************************************************************;
***>>STEP15: Run PROC CONTENTS ORDER=VARNUM on indexed version of HEART data set and use ODS TRACE;
***>>NOTE: Review the log carefully for output data sets;
***>>NOTE: Review the files in the results window; 
*** PROC CONTENTS VARNUM with on indexed version of data set;

ods trace on;

proc contents data=out1.heart_index varnum;
title2 "Contents on Corrected Data Set - Add Index";
run;

ods trace off;

*******************************************************************;
***	Harvesting ODS Output Objects								***;
*******************************************************************;
***>>STEP16: Check the Trace Results in the Log and record the temporary data set names;
***>>STEP16: Write an ODS OUTPUT code sandwich to output to work files and close ODS Output;
***>>STEP16: PROC CONTENTS and test prints on each ODS output file; ;

ods output indexes=indexes;

proc contents data=out1.heart_index varnum;
title2 "Contents on Corrected Data Set - ODS Output Indexes";
run;

ods output close;

proc contents data=indexes varnum;
title2 'Contents of Indexes ODS Output Object';
run;

proc print data=indexes noobs;
title2 'Test Print Indexes ODS Output Object';
run;

***********************************************************************************;
*** End of PROC CONTENTS Exercises												***;
***********************************************************************************;

***********************************************************************************;
*** Start of Statistical Procedure Exercises									***;
***********************************************************************************;

*******************************************************************;
***	Using Univariate Outtable									***;
*******************************************************************;
***>>STEP17: Run PROC UNIVARIATE on BMI in the HEART data set and use ODS TRACE;
***>>STEP17: RUN PROC UNIVARIATE OUTTABLE in the HEART data set and use ODS TRACE;
***>>NOTE: Review the files in the results window; 
*** PROC CONTENTS VARNUM with on indexed version of data set;

ods trace on;

proc univariate data=out1.heart;
    var bmi;
title2 "Univariate on BMI";
run;

proc univariate data=out1.heart outtable=heart_outtable noprint;
    var _numeric_;
run;

proc print data=heart_outtable noobs;
title2 "PROC UNIVARIATE OUTTABLE - Heart Numeric Variables";
run;

ods trace off;

ods output moments=moments1 basicmeasures=basicmeasures1 testsforlocation=testsforlocation1
				quantiles=quantiles1 extremeobs=extremeobs1 missingvalues=missingvalues1;

proc univariate data=out1.heart;
    var bmi;
title2 "Univariate on BMI";
run;

ods output close;

*******************************************************************;
***	Harvesting ODS Output Objects								***;
*******************************************************************;
***>>STEP18: Check the Trace Results in the Log and record the temporary data set names;
***>>STEP18: Write an ODS OUTPUT code sandwich to output to work files and close ODS Output;
***>>STEP18: PROC CONTENTS and test prints on each ODS output file; ;

proc contents data=moments1 varnum;
title2 "PROC CONTENTS on UNIVARIATE MOMENTS1 ODS OUTPUT object";
run;

proc print data=moments1 (obs=5) noobs;
title2 "Test print on UNIVARIATE MOMENTS1 ODS OUTPUT object";
run;

proc contents data=basicmeasures1 varnum;
title2 "PROC CONTENTS on UNIVARIATE BASIC MEASURES 1 ODS OUTPUT object";
run;

proc print data=basicmeasures1 (obs=5) noobs;
title2 "Test print on UNIVARIATE BASIC MEASURES 1 ODS OUTPUT object";
run;

proc contents data=testsforlocation1 varnum;
title2 "PROC CONTENTS on UNIVARIATE TESTSFORLOCATION1 ODS OUTPUT object";
run;

proc print data=testsforlocation1 (obs=5) noobs;
title2 "Test print on UNIVARIATE TESTSFORLOCATION1 ODS OUTPUT object";
run;

proc contents data=quantiles1 varnum;
title2 "PROC CONTENTS on UNIVARIATE QUANTILES1 ODS OUTPUT object";
run;

proc print data=quantiles1 (obs=5) noobs;
title2 "Test print on UNIVARIATE QUANTILES1 ODS OUTPUT object";
run;

proc contents data=extremeobs1 varnum;
title2 "PROC CONTENTS on UNIVARIATE EXTREME OBS 1 ODS OUTPUT object";
run;

proc print data=extremeobs1 (obs=5) noobs;
title2 "Test print on UNIVARIATE EXTREME OBS 1 ODS OUTPUT object";
run;

proc contents data=missingvalues1 varnum;
title2 "PROC CONTENTS on UNIVARIATE MISSINGVALUES1 ODS OUTPUT object";
run;

proc print data=missingvalues1 (obs=5) noobs;
title2 "Test print on UNIVARIATE MISSINGVALUES1 ODS OUTPUT object";
run;

*******************************************************************;
***	PROC UNIVARIATE PLOT OUTPUT									***;
*******************************************************************;
***>>STEP19: Sort the HEART data set by sex and create a heartplots data set;
***>>STEP19: Turn on ODS LISTING SGE (SAS Graphics Editor) and ODS GRAPHICS;
***>>STEP19: RUN PROC UNIVARIATE on the HEARTPLOTS data set with the plot option and use ODS TRACE;
***>>NOTE: Review the files in the results window; 
***>>NOTE: Review the files in the log;

proc sort data=out1.heart out=heartplots;
    by sex;
run;

ods listing sge=on;
ods graphics on;
ods trace on;

proc univariate data=heartplots plot;
   by sex;
   var bmi;
title2 "PROC UNIVARIATE PLOTS";
run;
ods graphics off;

ods graphics on;
ods select Plots SSPlots;
proc univariate data=heartplots plot;
   by sex;
   var bmi;
title2 "PROC UNIVARIATE PLOTS";
run;
ods graphics off;
ods select all;
ods trace off;


ods trace on;

proc freq data=out1.heart;
    tables bmi_cat*obesity_cat / missing list;
title2 "Obesity coding test";
run;

ods trace off;

title2 "Logistics";
run;

ods trace on;
ods output parameterestimates=parameterestimates oddsratios=oddsratios;

proc logistic data=out1.heart;
    class sex;
    model status = AgeAtStart 
	               sex
                   mrw 
                   smoking 
				   bmi_cat
                   ;
run;

ods output close;
ods trace off;

proc print data=parameterestimates (obs=20) noobs;
title2 "Logistics Parameter Estimates";
run;

proc contents data=parameterestimates varnum;
run;

proc print data=oddsratios (obs=20) noobs;
title2 "Logistics Odds Ratios";
run;

proc contents data=oddsratios varnum;
run;

title2;
run;

proc format;
	value num2lab 1 = "Age at Start"
	              2 = "Female versus Male"
				  3 = "MRW"
				  4 = "Smoking Status"
				  5 = "BMI Category";
run;

data param;
    length rowlabel $ 40;
    set parameterestimates (where=(variable ne "Intercept"));
    order=_n_;
	rowlabel=put(order,num2lab.);
run;

data odds;
    length rowlabel $ 40;
    set oddsratios;
	if effect="Sex Female vs Male" then effect="Sex";
	order=_n_;
	rowlabel=put(order,num2lab.);
run;

proc print data=param (obs=10) noobs;
run;

proc print data=odds (obs=10) noobs;
run;

proc sort data=param out=param_sort;
    by order;
run;

proc sort data=odds out=odds_sort;
    by order;
run;

data test_design;
    merge param_sort odds_sort;
	by order;
run;

proc print data=test_design (obs=10) noobs;
title2 "Test Designer Data Set";
run;










  






