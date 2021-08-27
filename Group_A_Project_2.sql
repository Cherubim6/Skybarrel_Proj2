				/* This is Project 2 */

USE [SkyBarrelBank_UAT];

/* ------------------------------------  REPORT 1 A:   -----------------------------------------------
The Director of Credit Analytics wants a report of ALL borrowers who HAVE taken a loan with the bank. 
(We are only interested in borrowers who have a loan in the LoanSetup table). 
For each borrower, return the below fields: 
a) BorrowerID
b) Borrower Full Name
c) SSN (database field: TaxPayerID_SSN). Please mask the first five digits of the SSN
d) Year the loan was purchased
e) The amount purchased in thousands in this format ($44,068K)    ------------------------------- */

----- Use Join Function to join colums from [dbo].[Borrower] and [dbo].[LoanSetupInformation]
---Note* -- inner join will only join matching rows of customers with loans from both tables.

Select DISTINCT Borrower.BorrowerID   ---- Would using the DISTINCT function eliminate a second loan if a Borrower has two loans????
		, Concat_ws(' ', BorrowerFirstName, BorrowerMiddleInitial, BorrowerLastName) AS Full_Name
		, Concat('--- ', '-- ', Right([TaxPayerID_SSN], 4)) AS SSN_Last_4
		, DATEPART (Year, PurchaseDate) AS Purchase_Year
		, FORMAT (LoanSetupInformation.PurchaseAmount/1000000, 'c4', 'en-us')+ 'M' AS Amount_Purchased
		From Borrower
		INNER JOIN LoanSetupInformation  
		on Borrower.BorrowerID = LoanSetupInformation.BorrowerID;


/* ------------------------------------  REPORT 1 B:   -----------------------------------------------
Generate a similar list to the one above, this time, show all customers, EVEN THOSE WITHOUT LOANS. 
Return it with similar columns as above. */

----- Use Join Function to join colums from [dbo].[Borrower] and [dbo].[LoanSetupInformation]
---Note* -- A left join will join all records (20k customers) from Table Borrower along with matching records from Table LoanSetupInformation .

Select DISTINCT Borrower.BorrowerID  ---- Would using the DISTINCT function eliminate a second loan if a Borrower has two loans????
		, Concat(BorrowerFirstName, '  ' ,BorrowerMiddleInitial,  '  ' ,BorrowerLastName) AS Full_Name
		, Concat('--- ', '-- ', Right([TaxPayerID_SSN], 4)) AS SSN_Last_4
		, DATEPART (Year, PurchaseDate) AS Purchase_Year
		, FORMAT (LoanSetupInformation.PurchaseAmount/1000000, 'c4', 'en-us')+ 'M' AS Amount_Purchased
		From Borrower
		LEFT JOIN LoanSetupInformation  --left join will join all record (20k customers) from Table Borrower with Table LoanSetupInformation 
		on Borrower.BorrowerID = LoanSetupInformation.BorrowerID;
		

/* -------------------------------------------  REPORT 2  A --------------------------------------------------------
Aggregate the borrowers by country and show per country:
a) The total purchase amount, 
b) Average purchase amount,
c) Count of borrowers,
d) Average LTV, 
e) Minimum LTV, 
f) Maximum LTV 
g) Average age of the borrowers.
Order the report by the Total Purchase Amount in descending order    -------------------------------------------- */

---Note* -------- Use the INNER JOIN to join colums from [dbo].[Borrower] and [dbo].[LoanSetupInformation]

Select Citizenship , 
		[Total Purchase Amount] = FORMAT(SUM(PurchaseAmount), 'c0'),
		[AVG Purchase Amount] = Format (AVG(PurchaseAmount), 'C0'),
		[Total Count of Borrowers] = Count(Borr.BorrowerID),
		[AVG Life Time Value] = Format (AVG(LTV), 'P1'),
		[MIN Life Time Value] = Format (MIN(LTV), 'P1'),
		[MAX Life Time Value] = Format (MAX(LTV), 'P1'),
		[Average Age of Borrower] = AVG(Datediff(year,DOB,GetDate()))
		FROM [dbo].[Borrower] AS Borr
		INNER JOIN
		[LoanSetupInformation] AS Setup
		on Borr.[BorrowerID]= Setup.[BorrowerID]
		GROUP BY Citizenship
		Order by [Total Purchase Amount] desc


/* ------------------------------------------------  Report 2 B: ----------------------------------------------
Aggregate the borrowers by gender ( If the gender is missing or is blank, please replace it with X) and show, per country,
h) The total purchase amount,
i) Average purchase amount,
j) Count of borrowers,
k) Average ltv,
l) Minimum ltv,
m) Maximum ltv
n) Average age of the borrowers
- Order the report by the Total Purchase Amount in descending order
- HINT > SELECT FORMAT(10000.004, 'c0')    ---------------------------------------------------------------------- */

---Note* ------ If the gender is missing or is blank, please replace it with X

Select  Citizenship, 
		count( case when gender='M'  then 1 end ) as Male,
		count( case when gender='F'  then 1 end ) as Female,
		count( case when gender=''   then 1 end ) as 'Gender X',
		[Total No. of Borrowers] = Count([Borrower].BorrowerID),
		[Average Age] = AVG(Datediff(year,DOB,GetDate())),
		[Total Purchase Amount] = FORMAT(SUM(PurchaseAmount), 'c0'),
		[AVG Purchase Amount] = FORMAT (AVG(PurchaseAmount),'c0'),
		[AVG Life Time Value] = Format (AVG(LTV), 'P'),
		[MIN Life Time Value] = Format (MIN(LTV), 'P1'),
		[MAX Life Time Value] = Format (MAX(LTV), 'P1')
		From [dbo].[Borrower]
		INNER JOIN
		[dbo].[LoanSetupInformation]
		on [Borrower].[BorrowerID]= [LoanSetupInformation].[BorrowerID]
		GROUP BY [Citizenship]
		Order by [Total Purchase Amount] desc
		

/*   ------------------------------Report 2	(c): -----------------------------------------
Aggregate the borrowers by gender (Only for F and M gender) and show, per country,
o) The total purchase amount,
p) Average purchase amount,
q) Count of borrowers,
r) Average ltv,
s) Minimum ltv,
t) Maximum ltv
u) Average age of the borrowers
- Order the report by the Year in Descending order and Gender ------------------------------- */
	 
---Note* ------ by gender (Only for F and M gender)

Select [Gender Type]  = [Gender],
		[Citizenship],
		[Total No. of Borrowers] = Count(Borr.BorrowerID),
		[Year of Purchase] = YEAR(PurchaseDate),
		[Average Age] = AVG(Datediff(year,DOB,GetDate())),
		[Total Purchase Amount] = FORMAT(SUM(PurchaseAmount), 'c0'),
		[AVG Purchase Amount] = FORMAT (AVG(PurchaseAmount),'c0'),
		[AVG Life Time Value] = Format (AVG(LTV), 'P'),
		[MIN Life Time Value] = Format (MIN(LTV), 'P1'),
		[MAX Life Time Value] = Format (MAX(LTV), 'P1')
		FROM [LoanSetupInformation] AS Setup
		inner join
		[dbo].[Borrower] AS Borr
		on Borr.[BorrowerID]= Setup.[BorrowerID]
		Where [Gender] = 'M' or [Gender] = 'F'
		GROUP BY [Citizenship], [Gender], [PurchaseDate], YEAR(PurchaseDate)
		Order by [Citizenship], Gender, [PurchaseDate] desc


/*   ------------------------------Report 3 --------------------------------------------
Calculate the years to maturity for each loan( Only loans that have a maturity date in the future) 
and then categorize them in bins of years (0-5, 6-10, 11-15, 16-20, 21-25, 26-30, >30).
Show the number of loans in each bins and the total purchase amount for each bin in billions HINT:
SELECT FORMAT(10000457.004, '$0,,,.000B') -------------------------------------------------------- */

Select 
		case 
		     when Year(MaturityDate) - Year(PurchaseDate) <= 5 then '0-5'
			 when Year(MaturityDate) - Year(PurchaseDate) <= 10 then '6-10'
			 when Year(MaturityDate) - Year(PurchaseDate) <= 15 then '11-15'
			 when Year(MaturityDate) - Year(PurchaseDate) <= 20 then '16-20'
			 when Year(MaturityDate) - Year(PurchaseDate) <= 25 then '21-25'
			 when Year(MaturityDate) - Year(PurchaseDate) <= 30 then '26-30'
			 when Year(MaturityDate) - Year(PurchaseDate) > 30 then '>30'
		end AS [Year Left to Maturity],
    Count(LoanNumber) AS [No. of Loans],
	[Total Purchase Amount] = FORMAT(SUM(PurchaseAmount/1000000000), 'c4', 'en-us')+ 'B'
from [LoanSetupInformation]
GROUP BY  Year(MaturityDate) - Year(PurchaseDate)

																	   									 
/*   ------------------------------Report 4 --------------------------------------------
Aggregate the Number of Loans by Year of Purchase and the Payment frequency description column found in the
LU_Payment_Frequency table  
------------------------------------------------------------------------------------------- */

---Selected columns from 3 tables( Borrower, LoanSetupInformation and LU_PaymentFrequency to build a more descriptive report) 

SELECT  [Year of Purchase]= YEAR(LS.PurchaseDate),
		PF.PaymentFrequency_Description,
		[No. Of Loans] = count(ProductID)
	From LU_PaymentFrequency AS PF
	INNER JOIN LoanSetupInformation AS LS
	ON PF.PaymentFrequency = LS.PaymentFrequency
	GROUP BY YEAR(LS.PurchaseDate), PF.PaymentFrequency_Description
	ORDER BY YEAR(LS.PurchaseDate) DESC
