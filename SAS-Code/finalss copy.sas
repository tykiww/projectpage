filename shortcut "/folders/myfolders/BYU_Data/*.txt";


proc format;
invalue lettertnum
"A" = 4.0
"A-" = 3.7
"B+" = 3.4
"B" = 3.0
"B-" = 2.7
"C+" = 2.4
"C" = 2.0
"C-" = 1.7
"D+" = 1.4
"D" = 1.0
"D-" = 0.7
"E" = 0.0
"UW" = 0.0
"IE" = 0.0
"WE" = 0.0
"W" = 0.0
"P" = 0.0
"I" = 0.0
"T" = 0.0;
run;
/*----------------REPORT ONE----------------*/

data final;
infile shortcut dlm="@";
length ID $ 5. Course $ 10.;
input ID $ Date Course $ Hours Grade $;
GPAgrade=input (Grade,lettertnum.);
Term = substrn(Date,1,1);
Year = 1900 + substrn(Date,2,2);
if GPAgrade > 0 or grade in ("E","UW","IE","WE") then gradedhours = Hours;
else gradedhours = 0;
if GPAgrade > 0 then ghoursearned = Hours;
else ghoursearned = 0;
if GPAgrade > 0 or grade in ("P") then earnedhours = Hours;
else earnedhours = 0;
run;

* delete I and T from grades;
proc sql;
delete
from final
where Grade = "I" && "T";
quit;


* Number of courses;
proc sql;
create table courses as
select *
from final
order by ID, Course, Year, Term;
quit;

* # of repeat classes;
data repeats;
set courses;
by ID Course;
if last.Course then repeat = 0;
else repeat = 1;
run;

proc sql;
update repeats
set earnedhours=0 where repeat=1;
update repeats
set ghoursearned=0 where repeat=1;
quit;

*Frequency of Letter Grade by Student by Semester;
proc sql;
create table grades as
select *,
case when Grade in ("A-","A") then 1 else 0 end as A,
case when Grade in ("B-","B","B+") then 1 else 0 end as B,
case when Grade in ("C-","C","C+") then 1 else 0 end as C,
case when Grade in ("D-","D","D+") then 1 else 0 end as D,
case when Grade in ("E","UW","WE","IE") then 1 else 0 end as E,
case when Grade in ("W") then 1 else 0 end as W
from repeats;
quit;

*GPA grade without repeats;
data real;
set grades;
if repeat = 1 then GPAgrade = 0;
run;

*Number of times each grade letter is repeated;
proc sql;
create table final2 as
select 
ID, 
Year, 
Term, sum(ghoursearned*GPAgrade)/sum(ghoursearned) as GPA, 
sum(ghoursearned*GPAgrade) as weight, 
sum(Hours) as SemHours, 
sum(gradedhours) as gradedhours, 
sum(earnedhours) as earnedhours, 
sum(ghoursearned) as ghoursearned, 
sum(A) as A, 
sum(B) as B, 
sum(C) as C,
sum(D) as D, 
sum(E) as E, 
sum(W) as W, 
sum(repeat) as repeatclasses
from real
group by ID, Year, Term;
quit;

*Cumulative GPA;
data gpacum;
set final2;
by ID;
retain cumWeight 0;
if first.ID then cumWeight = 0;
cumWeight + weight;
retain cumHours 0;
if first.ID then cumHours = 0;
cumHours + SemHours;
run;

*continuation + class standing;
data class_standing_num;
length class_standing $ 10;
set gpacum;
by ID;
retain cumearned 0;
if first.ID then cumearned = 0;
cumearned + earnedhours;
retain cumgraded 0;
if first.ID then cumgraded = 0;
cumgraded + gradedhours;
retain cumgradedearned 0;
if first.ID then cumgradedearned = 0;
cumgradedearned + ghoursearned;
retain cumA 0;
if first.ID then cumA = 0;
cumA + A;
retain cumB 0;
if first.ID then cumB = 0;
cumB + B;
retain cumC 0;
if first.ID then cumC = 0;
cumC + C;
retain cumD 0;
if first.ID then cumD = 0;
cumD + D;
retain cumE 0;
if first.ID then cumE = 0;
cumE + E;
retain cumW 0;
if first.ID then cumW = 0;
cumW + W;
retain cumrep 0;
if first.ID then cumrep = 0;
cumrep + repeatclasses;
if cumearned le 29.9 then class_standing = "Freshman";
if cumearned ge 30 and cumearned le 59.9 then class_standing = "Sophomore";
if cumearned ge 60 and cumearned le 89.9 then class_standing = "Junior";
if cumearned ge 90 then class_standing = "Senior";
cumgpa = cumWeight/cumgradedearned;
run;

*reorganized;
data placeholder;
set class_standing_num;
by ID;
if last.ID;
run;

*reorganized;
proc sql;
create table placeholder2 as
select c.*, 
s.cumgpa as overallgpa, 
s.cumearned as overallearned, 
s.cumgradedearned as ogradedearned, 
s.cumA as totalA,
s.cumB as totalB, 
s.cumC as totalC, 
s.cumD as totalD, 
s.cumE as totalE, 
s.cumW as totalW, 
s.cumrep as repeatedclasses
from class_standing_num as c, placeholder as s
where c.ID=s.ID;


*report one, complete. Compiled previous;
proc sql;
create table report_one as
select 
ID, 
Year, 
Term, 
GPA, 
cumGPA, 
earnedhours, 
ghoursearned, 
class_standing, 
overallgpa, 
overallearned, 
ogradedearned, 
repeatedclasses, 
totalA, 
totalB, 
totalC, 
totalD, 
totalE, 
totalW
from placeholder2 
order by ID, Year, Term;
quit;

/*----------------REPORT TWO----------------*/
*extracting only math and stat classes. Performing outer join;
proc sql;
create table math as
select * from final where Course like "MATH%";
create table stat as
select * from final where Course like "STAT%";
create table mathstat as
select * from math
union
select * from stat;
quit;

*Same as above, now with mathstat dataset;
proc sql;
create table mscourses as
select *
from mathstat
order by ID, Course, Year, Term;
quit;

data msrepeats;
set mscourses;
by ID Course;
if last.Course then repeat = 0;
else repeat = 1;
run;

proc sql;
update msrepeats
set earnedhours=0 where repeat=1;
update msrepeats
set ghoursearned=0 where repeat=1;
quit;

proc sql;
create table msgrades as
select *,
case when Grade in ("A-","A") then 1 else 0 end as A,
case when Grade in ("B-","B","B+") then 1 else 0 end as B,
case when Grade in ("C-","C","C+") then 1 else 0 end as C,
case when Grade in ("D-","D","D+") then 1 else 0 end as D,
case when Grade in ("E","UW","WE","IE") then 1 else 0 end as E,
case when Grade in ("W") then 1 else 0 end as W
from msrepeats;
quit;

data msreal;
set msgrades;
if repeat = 1 then GPAgrade = 0;
run;

 proc sql;
create table msfinals as
select 
ID, 
Year, 
Term, 
sum(ghoursearned*GPAgrade)/sum(ghoursearned) as GPA, 
sum(ghoursearned*GPAgrade) as weight, 
sum(Hours) as SemHours, 
sum(gradedhours) as gradedhours, 
sum(earnedhours) as earnedhours, 
sum(ghoursearned) as ghoursearned, 
sum(A) as A, 
sum(B) as B, 
sum(C) as C,
sum(D) as D, 
sum(E) as E, 
sum(W) as W, 
sum(repeat) as repeatclasses
from msreal
group by ID, Year, Term;
quit;

data msgpacum;
set msfinals;
by ID;
retain cumWeight 0;
if first.ID then cumWeight = 0;
cumWeight + weight;
retain cumHours 0;
if first.ID then cumHours = 0;
cumHours + SemHours;
run;

data msclass_standing_count;
length class_standing $ 10;
set msgpacum;
by ID;
retain cumearned 0;
if first.ID then cumearned = 0;
cumearned + earnedhours;
retain cumgraded 0;
if first.ID then cumgraded = 0;
cumgraded + gradedhours;
retain cumgradedearned 0;
if first.ID then cumgradedearned = 0;
cumgradedearned + ghoursearned;
retain cumA 0;
if first.ID then cumA = 0;
cumA + A;
retain cumB 0;
if first.ID then cumB = 0;
cumB + B;
retain cumC 0;
if first.ID then cumC = 0;
cumC + C;
retain cumD 0;
if first.ID then cumD = 0;
cumD + D;
retain cumE 0;
if first.ID then cumE = 0;
cumE + E;
retain cumW 0;
if first.ID then cumW = 0;
cumW + W;
retain cumrep 0;
if first.ID then cumrep = 0;
cumrep + repeatclasses;
if cumearned le 29.9 then class_standing = "Freshman";
if cumearned ge 30 and cumearned le 59.9 then class_standing = "Sophomore";
if cumearned ge 60 and cumearned le 89.9 then class_standing = "Junior";
if cumearned ge 90 then class_standing = "Senior";
cumgpa = cumWeight/cumgradedearned;
run;

data msplaceholder;
set msclass_standing_count;
by ID;
if last.ID;
run;

proc sql;
create table msplaceholder as
select 
mc.*, 
mph.cumgpa as overallgpa, 
mph.cumearned as overallearned, 
mph.cumgradedearned as ogradedearned, 
mph.cumA as totalA,
mph.cumB as totalB, 
mph.cumC as totalC, 
mph.cumD as totalD, 
mph.cumE as totalE, 
mph.cumW as totalW, 
mph.cumrep as repeatedclasses
from msclass_standing_count as mc, msplaceholder as mph
where mc.ID=mph.ID;
quit;

proc sql;
create table msreport_one as
select 
ID, 
Year, 
Term, 
GPA as msGPA, 
cumGPA as mscumGPA, 
earnedhours as msearnedhours,
ghoursearned as msghoursearned, 
class_standing, 
overallgpa as msoverallgpa, 
overallearned as msoverallearned, 
ogradedearned as msogradedearned,
repeatedclasses as msrepeatedclasses, 
totalA as mstotalA, 
totalB as mstotalB, 
totalC as mstotalC,
totalD as mstotalD, 
totalE as mstotalE, 
totalW as mstotalW
from msplaceholder
order by ID, Year, Term;
quit;

proc sql;
create table report_two as
select distinct 
f.ID, 
f.overallgpa, 
f.overallearned, 
f.ogradedearned, 
f.repeatedclasses, 
f.totalA, 
f.totalB, 
f.totalC,
f.totalD, 
f.totalE, 
f.totalW, 
ms.msoverallgpa, 
ms.msoverallearned, 
ms.msogradedearned, 
ms.msrepeatedclasses,
ms.mstotalA, 
ms.mstotalB, 
ms.mstotalC, 
ms.mstotalD, 
ms.mstotalE, 
ms.mstotalW
from report_one as f, msreport_one as ms
where f.ID=ms.ID and f.Year=ms.Year and f.Term=ms.Term;
quit;

/*--------REPORT THREE----------*/

%macro whoo(dataset);

proc sql;
create table top_students as
select *
from &dataset.
order by overallgpa descending;
quit;

data &dataset.top_ten;
set top_students;
if _n_/&sqlobs. gt .1 then stop;
output;
run;

%mend;

data report_three (keep= ID overallgpa);
set report_two;
by ID;
if overallearned ge 60.0 and overallearned le 130.0 then output;
run;

%whoo(report_three);


/*--------REPORT FOUR----------*/
data report_four (keep= ID overallgpa);
set report_two;
by ID;
if msogradedearned ge 20.0 then output;
run;

%whoo(report_four);


/*----formatting----*/
proc datasets noprint;
modify report_one;
format GPA cumgpa overallgpa 8.2;
run;

proc datasets noprint;
modify report_two;
format overallgpa msoverallgpa 8.2;
run;

proc datasets noprint;
modify report_threetop_ten;
format overallgpa 8.2;
run;

proc datasets noprint;
modify report_fourtop_ten;
format overallgpa 8.2;
run;

/*-----ods output-----*/

ods html file="/folders/myfolders/poopie.html";

proc report data=report_one;
title "Report 1";
label cumgpa="Cumulative GPA" 
earnedhours="Credit Hours Earned" 
ghoursearned="Graded Credit Hours Earned"
class_standing="Class Standing" 
overallgpa="Overall GPA" 
overallearned="Total Credit Hours Earned"
ogradedearned="Total Graded Credit Hours Earned" 
repeatedclasses="Number of Repeated Classes" 
totalA="Total A's"
totalB="Total B's" 
totalC="Total C's" 
totalD="Total D's" 
totalE="total E's/UW's/WE's/IE's" 
totalW="Total W's";
run;

proc report data=report_two;
title "Report 2";
label overallgpa="Overall GPA" 
overallearned="Total Credit Hours Earned"
ogradedearned="Total Graded Credit Hours Earned" 
repeatedclasses="Number of Repeated Classes" 
totalA="Total A's"
totalB="Total B's" 
totalC="Total C's" 
totalD="Total D's" 
totalE="total E's, UW's, WE's and IE's" 
totalW="Total W's"
msoverallgpa="Overall Math/Stats GPA" 
msoverallearned="Total Math/Stats Credit Hours Earned"
msogradedearned="Total Graded Math/Stats Credit Hours Earned" 
msrepeatedclasses="Number of Repeated Math/Stats Classes" 
mstotalA="Total Math & Stats A's"
mstotalB="Total Math & Stats B's" 
mstotalC="Total Math & Stats C's" 
mstotalD="Total Math & Stats D's" 
mstotalE="Total Math & Stats E's, UW's, WE's and IE's" 
mstotalW="Total Math & Stats W's";
run;

proc report data=report_threetop_ten;
title "Report 3";
label overallgpa="Overall GPA";
run;

proc report data=report_fourtop_ten;
title "Report 4";
label overallgpa="Overall GPA";
run;

ods html close;











