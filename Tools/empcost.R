

#' Find Labor Cost
#'
#' This function takes two separate situations. 
#' One is where an annual salary is already defined with total weeks worked and 
#' daily hours worked required. It assumes that the weekly days worked to be at 5.
#' Second scenario takes an hourly wage and requires total weeks worked and hours
#' worked per year. The final 
#'
#' Scenario 1.
#' @param ansalary The Annual Salary of an employee (if already known)
#' @param wkpy The range of total weeks worked in a year (1-52)
#' @param dhw The number of hours worked daily (>0)
#' @param wdw The number of weekly days worked. The default is 5.
#' Scenario 2.
#' @param wage Hourly wage of an employee (if already known)
#' @param wkpy The range of total weeks worked in a year (1-52)
#' @param dhw The number of hours worked daily (>0)
#' @param wdw The number of weekly days worked. The default is 5.
#' @return Will show annual salary, hourly wage, and hours per year of employee.
#' 
#' Some examples of this function include, but are not limited to:
#' 
#' emplabor(ansalary = 70000, wkpy = 50, dhw = 8)
#' emplabor(wage = 35, wkpy = 50, dhw = 8)
#' 
#' @export

emplabor <- function(ansalary = FALSE, wkpy = FALSE, dhw = FALSE, wage = FALSE, wdw = 5) {
  
  if (!ansalary) p <- 0
  else p <- 1
  
  if (p == 1) {
    hourwage <- ansalary / (wkpy * dhw * wdw)
    hoursperyear <- wkpy * dhw * wdw
    c("Annual Salary" = ansalary, "Hourly Wage" = hourwage, 
      "Annual Hours Worked" = hoursperyear)
  } else if (p == 0) {
    hoursperyear <- wkpy * dhw * wdw
    ansal <- wage*hoursperyear
    c("Annual Salary" = ansal, "Hourly Wage" = wage, 
      "Annual Hours Worked" = hoursperyear)
  }
}



#' Find Employee Overhead
#'
#'
#' This function takes the overhead produced per year and divides it by the number
#' of workers to produce the annual overhead per employee. It can be divided into
#' parts by building costs, utilities, benefits, etc. Or be manually input if the
#' ballpark or exact estimate of overhead is at hand.
#' 
#' The list of several possible overhead costs is as follows, but is not limited to:
#' 
#' Annual Building Costs, Annual Property Taxes, Annual Utilities, Annual Equipment 
#' & Supplies, Annual Insurance Paid, Annual Benefits Paid, training costs, hiring
#' costs.
#' 
#' @param tover Total Overhead manually input (annual)
#' @param count Number of employees working in environment.
#' 
#' If by happenstance you do not want to total up your overhead, you may also 
#' manually input the overhead in a vectorized format.
#'
#' @param sover Vector that takes in all overhead costs.
#' @return Will output the overhead per employee
#' 
#' Some examples of this function include, but are not limited to:
#' 
#' empover(count = 40, sover = c(40000,40000,40000,4000,4000))
#' empover(count = 40, sover = 200000)
#' 
#' @export


empover <- function(tover = FALSE,count,sover=FALSE) {
  options(warn=-1)
  if (sover == FALSE)  {
    overhead <- tover / count
  }
  else if (tover == FALSE) {
    overhead <- sum(sover) / count
  }
  options(warn=0)
  c("Overhead per employee" = overhead)
}


#' Find Per Employee Tax Cost
#' 
#' This function will allow you to connect with an external repository on github
#' to find the tax rate by state and taxable amount depending on the employee.
#' This includes FUTA, SUTA, Medicare, and Social Security for 2017. This is also
#' under the assumption that the employee receives at least the taxable amount in
#' the state.
#' 
#' The repository name url is under: 
#' https://github.com/tykiww/projectpage/blob/master/datasets/hr-cost/2017statetax.csv.  
#' 
#' @param state Name of State of Territory
#' @param salary employee annual wage.
#' @param count number of employees in firm.
#' @param taxes vector indicating which taxes are of interest. (FUTA, SUTA, SS, MED)
#' @param dataset default is FALSE. TRUE if you want to keep the dataset.
#' @return Will output the tax cost per employee to your firm.
#' 
#' Some examples of this function include, but are not limited to:
#' 
#' emptax("Alabama",70000,40, dataset = T)
#' emptax("Puerto Rico",70000,40, taxes = c("FUTA","SUTA"))
#' 
#' @export

emptax <- function(state,salary, count, taxes = FALSE, dataset = FALSE) {
  require(dplyr)
  # importing dataset.
  url <- "https://raw.githubusercontent.com/tykiww/projectpage/master/datasets/hr-cost/2017statetax.csv"
  setz <- read.csv(url, header = T)
  # Clean Set
  {
  setz <- setz[-1]
  setz$State <- as.character(setz$State)
  setz$Maximum <- (gsub("\\%","",setz$Maximum) %>% as.numeric) * .01
  setz$Minimum <- (gsub("\\%","",setz$Minimum) %>% as.numeric) * .01
  setz$Average <- (gsub("\\%","",setz$Average) %>% as.numeric) * .01
  setz$Taxable.Amount <- gsub("\\$","",setz$Taxable.Amount)
  setz$Taxable.Amount <- gsub(",","",setz$Taxable.Amount) %>% as.numeric
  setz$Average.Amount <- gsub("\\$","",setz$Average.Amount)
  setz$Average.Amount <- gsub(",","",setz$Average.Amount) %>% as.numeric
  }
  # Separate Tax
    # FUTA
    FUTA <- salary*0.6*.01/count
    # SUTA
    SUTA <- setz[setz$State %in% state,][6]
    names(SUTA) <- "SUTA"
    # Social Security
    SS <- salary*6.2*.01/count
    # Medicare
    MED <- salary*1.45*.01/count
  # New Tax Dataset
    dat <- t(cbind(FUTA,SUTA,SS,MED))
  # Output
    options(warn=-1)
  if (taxes == FALSE) {
    g <- sum(dat)
  } else {
    g <- sum(dat[rownames(dat) %in% taxes,])
  }  
    options(warn=0)
  if (dataset == T) {
    list(setz,g)
  } else {
    g
  }
}


#' Employee Cost
#' 
#' 
#' This function may be used in conjuction with functions emptax, empover, and 
#' emplabor to estimate the cost of an employee to a firm. There are also functions 
#' to determine the billable cost of an employee to a client and an estimated loss 
#' depending on the average count of employees that leave during a year.
#' 
#' @param wage Annual Salary for 1 employee
#' @param overhead Overhead for 1 employee
#' @param antax Annual Tax for 1 employee
#' @param extras Any extra costs to include (Hiring/Training) not mentioned in overhead
#' @param hours Annual Hours worked for 1 employee
#' @param leave Yearly average number of employees that leave.
#' @return True cost of employee, Billable Rate per hour, Overall Estimated loss to turnover.
#' 
#' Some examples of this function include, but are not limited to:
#' 
#' empcost(70000,5000,438.775,hours=2000,leave = 3)
#' empcost(70000,5000,438.775,hours=2000, extras = 210,leave=3)
#' 
#' @export


empcost <- function(wage,overhead,antax,extras=FALSE,hours,leave) {
  require(dplyr)
  if (extras == FALSE) {
    indcost <- c(wage,overhead,antax) %>% sum
  } else {
    indcost <- c(wage,overhead,antax,extras) %>% sum
  }
  
  billable <- indcost/hours
  loss <- indcost*leave
  list("True cost of employee"=indcost,
       "Employee billable cost/hour"=billable,
       "Overall estimated loss due to turnover"= loss)
}






