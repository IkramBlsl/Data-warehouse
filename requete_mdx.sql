--#Creation de la table sales_fact_projetDW AS

CREATE TABLE sales_fact_projetDW AS
SELECT * FROM sales_fact_1997
UNION ALL
SELECT * FROM sales_fact_1998
UNION ALL
SELECT * FROM sales_fact_dec_1998;


--###Indexer les colonnes des tables : 
CREATE INDEX idx_product_id ON sales_fact_projetDW(product_id);
CREATE INDEX idx_customer_id ON sales_fact_projetDW(customer_id);
CREATE INDEX idx_store_id ON sales_fact_projetDW(store_id);
CREATE INDEX idx_time_id ON sales_fact_projetDW(time_id);

--##################################################################################################
--Requête MDX 
--##################################################################################################
--Question 1 : 

--Avec Product Family : 

WITH 
MEMBER [Measures].[Percentage Sales] AS 
  ([Measures].[Store Sales] / Sum([Product].[Product Family].Members, [Measures].[Store Sales])),
FORMAT_STRING = "Percent"

SELECT 
  NON EMPTY 
    {[Product].[Product Family].Members} * 
    {[Yearly Income].[All Yearly Incomes].Children} * 
    {[Occupation].[All Occupations].Children} *
    {[Number_children_at_home].Members} ON ROWS,
  {[Measures].[Store Sales], [Measures].[Percentage Sales]} ON COLUMNS
FROM [projetDW]

--#################################################################################

--Product category :

WITH 
MEMBER [Measures].[Percentage Sales] AS 
  ([Measures].[Store Sales] / Sum([Product].[Product Family].Members, [Measures].[Store Sales])),
FORMAT_STRING = "Percent"

SELECT 
  NON EMPTY 
    {[Product].[Product Category].Members} * 
    {[Yearly Income].[All Yearly Incomes].Children} * 
    {[Occupation].[All Occupations].Children} *
    {[Number_children_at_home].Members} ON ROWS,
  {[Measures].[Store Sales], [Measures].[Percentage Sales]} ON COLUMNS
FROM [projetDW]

--##################################################################################################
--Question 2 : 

--pour toutes les catégories (Product category) dans la famille de boissons
-- (drink), dans la famille de nourritures (food), dans la famille de non consommable

WITH
member [Measures].[MoyenMobileCentre Store Sales] AS
'iif(isEmpty([Time].PrevMember), 

		(([Time].CurrentMember, [Measures].[Store sales])+ ([Time].NextMember, [Measures].[Store sales]))/2 ,

		iif(isEmpty([Time].NextMember),

			 (([Time].PrevMember, [Measures].[Store sales]) +([Time].CurrentMember, [Measures].[Store sales]))/2,

			(([Time].PrevMember, [Measures].[Store sales]) + 
			([Time].CurrentMember, [Measures].[Store sales]) + 
			([Time].NextMember, [Measures].[Store sales]))/3 
		)
 )'

  member [Measures].[MoyenMobileCentre Store Cost] AS
'iif(isEmpty([Time].PrevMember), 

		(([Time].CurrentMember, [Measures].[Store Cost])+ ([Time].NextMember, [Measures].[Store Cost]))/2 ,

		iif(isEmpty([Time].NextMember),

			 (([Time].PrevMember, [Measures].[Store Cost]) +([Time].CurrentMember, [Measures].[Store Cost]))/2,

			(([Time].PrevMember, [Measures].[Store Cost]) + 
			([Time].CurrentMember, [Measures].[Store Cost]) + 
			([Time].NextMember, [Measures].[Store Cost]))/3 
		)
 )'

member [Measures].[MoyenMobileCentre Unit Sales] AS
'iif(isEmpty([Time].PrevMember), 

		(([Time].CurrentMember, [Measures].[Unit sales])+ ([Time].NextMember, [Measures].[Unit sales]))/2 ,

		iif(isEmpty([Time].NextMember),

			 (([Time].PrevMember, [Measures].[Unit sales]) +([Time].CurrentMember, [Measures].[Unit sales]))/2,

			(([Time].PrevMember, [Measures].[Unit sales]) + 
			([Time].CurrentMember, [Measures].[Unit sales]) + 
			([Time].NextMember, [Measures].[Unit sales]))/3 
		)
 )'

SELECT {[Measures].[MoyenMobileCentre Store Sales],
		[Measures].[MoyenMobileCentre Store Cost],
		[Measures].[MoyenMobileCentre Unit Sales]}
ON Columns, 
CrossJoin({Descendants([Time].[1997],2), Descendants([Time].[1998],2)}, 
 		{[Product].[Product Category].members} )
 		 ON ROWS
from [projetDW]


--pour les différents niveaux de revenu
WITH
member [Measures].[MoyenMobileCentre Store Sales] AS
'iif(isEmpty([Time].PrevMember), 

		(([Time].CurrentMember, [Measures].[Store sales])+ ([Time].NextMember, [Measures].[Store sales]))/2 ,

		iif(isEmpty([Time].NextMember),

			 (([Time].PrevMember, [Measures].[Store sales]) +([Time].CurrentMember, [Measures].[Store sales]))/2,

			(([Time].PrevMember, [Measures].[Store sales]) + 
			([Time].CurrentMember, [Measures].[Store sales]) + 
			([Time].NextMember, [Measures].[Store sales]))/3 
		)
 )'

  member [Measures].[MoyenMobileCentre Store Cost] AS
'iif(isEmpty([Time].PrevMember), 

		(([Time].CurrentMember, [Measures].[Store Cost])+ ([Time].NextMember, [Measures].[Store Cost]))/2 ,

		iif(isEmpty([Time].NextMember),

			 (([Time].PrevMember, [Measures].[Store Cost]) +([Time].CurrentMember, [Measures].[Store Cost]))/2,

			(([Time].PrevMember, [Measures].[Store Cost]) + 
			([Time].CurrentMember, [Measures].[Store Cost]) + 
			([Time].NextMember, [Measures].[Store Cost]))/3 
		)
 )'

member [Measures].[MoyenMobileCentre Unit Sales] AS
'iif(isEmpty([Time].PrevMember), 

		(([Time].CurrentMember, [Measures].[Unit sales])+ ([Time].NextMember, [Measures].[Unit sales]))/2 ,

		iif(isEmpty([Time].NextMember),

			 (([Time].PrevMember, [Measures].[Unit sales]) +([Time].CurrentMember, [Measures].[Unit sales]))/2,

			(([Time].PrevMember, [Measures].[Unit sales]) + 
			([Time].CurrentMember, [Measures].[Unit sales]) + 
			([Time].NextMember, [Measures].[Unit sales]))/3 
		)
 )'

SELECT {[Measures].[MoyenMobileCentre Store Sales],
		[Measures].[MoyenMobileCentre Store Cost],
		[Measures].[MoyenMobileCentre Unit Sales]}
ON Columns, 
CrossJoin({Descendants([Time].[1997],2), Descendants([Time].[1998],2)}, 
 		{[Occupation].members} )
 		 ON ROWS
from [projetDW]

--pour les différents niveau d''éducatiON


WITH
member [Measures].[MoyenMobileCentre Store Sales] AS
'iif(isEmpty([Time].PrevMember), 

		(([Time].CurrentMember, [Measures].[Store sales])+ ([Time].NextMember, [Measures].[Store sales]))/2 ,

		iif(isEmpty([Time].NextMember),

			 (([Time].PrevMember, [MeASures].[Store sales]) +([Time].CurrentMember, [Measures].[Store sales]))/2,

			(([Time].PrevMember, [Measures].[Store sales]) + 
			([Time].CurrentMember, [Measures].[Store sales]) + 
			([Time].NextMember, [Measures].[Store sales]))/3 
		)
 )'

  member [Measures].[MoyenMobileCentre Store Cost] AS
'iif(isEmpty([Time].PrevMember), 

		(([Time].CurrentMember, [Measures].[Store Cost])+ ([Time].NextMember, [Measures].[Store Cost]))/2 ,

		iif(isEmpty([Time].NextMember),

			 (([Time].PrevMember, [Measures].[Store Cost]) +([Time].CurrentMember, [Measures].[Store Cost]))/2,

			(([Time].PrevMember, [Measures].[Store Cost]) + 
			([Time].CurrentMember, [Measures].[Store Cost]) + 
			([Time].NextMember, [Measures].[Store Cost]))/3 
		)
 )'

member [Measures].[MoyenMobileCentre Unit Sales] AS
'iif(isEmpty([Time].PrevMember), 

		(([Time].CurrentMember, [Measures].[Unit sales])+ ([Time].NextMember, [Measures].[Unit sales]))/2 ,

		iif(isEmpty([Time].NextMember),

			 (([Time].PrevMember, [Measures].[Unit sales]) +([Time].CurrentMember, [Measures].[Unit sales]))/2,

			(([Time].PrevMember, [Measures].[Unit sales]) + 
			([Time].CurrentMember, [Measures].[Unit sales]) + 
			([Time].NextMember, [Measures].[Unit sales]))/3 
		)
 )'

SELECT {[Measures].[MoyenMobileCentre Store Sales],
		[Measures].[MoyenMobileCentre Store Cost],
		[Measures].[MoyenMobileCentre Unit Sales]}
ON Columns, 
CrossJoin({Descendants([Time].[1997],2), Descendants([Time].[1998],2)}, 
 		{[Education].members} )
 		 ON ROWS
from [projetDW]

--nombre d'enfant dans la maison


WITH
member [Measures].[MoyenMobileCentre Store Sales] AS
'iif(isEmpty([Time].PrevMember), 

		(([Time].CurrentMember, [Measures].[Store sales])+ ([Time].NextMember, [Measures].[Store sales]))/2 ,

		iif(isEmpty([Time].NextMember),

			 (([Time].PrevMember, [Measures].[Store sales]) +([Time].CurrentMember, [Measures].[Store sales]))/2,

			(([Time].PrevMember, [Measures].[Store sales]) + 
			([Time].CurrentMember, [Measures].[Store sales]) + 
			([Time].NextMember, [Measures].[Store sales]))/3 
		)
 )'

  member [Measures].[MoyenMobileCentre Store Cost] AS
'iif(isEmpty([Time].PrevMember), 

		(([Time].CurrentMember, [Measures].[Store Cost])+ ([Time].NextMember, [Measures].[Store Cost]))/2 ,

		iif(isEmpty([Time].NextMember),

			 (([Time].PrevMember, [Measures].[Store Cost]) +([Time].CurrentMember, [Measures].[Store Cost]))/2,

			(([Time].PrevMember, [Measures].[Store Cost]) + 
			([Time].CurrentMember, [Measures].[Store Cost]) + 
			([Time].NextMember, [Measures].[Store Cost]))/3 
		)
 )'

member [Measures].[MoyenMobileCentre Unit Sales] AS
'iif(isEmpty([Time].PrevMember), 

		(([Time].CurrentMember, [Measures].[Unit sales])+ ([Time].NextMember, [Measures].[Unit sales]))/2 ,

		iif(isEmpty([Time].NextMember),

			 (([Time].PrevMember, [Measures].[Unit sales]) +([Time].CurrentMember, [Measures].[Unit sales]))/2,

			(([Time].PrevMember, [Measures].[Unit sales]) + 
			([Time].CurrentMember, [Measures].[Unit sales]) + 
			([Time].NextMember, [Measures].[Unit sales]))/3 
		)
 )'

SELECT {[Measures].[MoyenMobileCentre Store Sales],
		[Measures].[MoyenMobileCentre Store Cost],
		[Measures].[MoyenMobileCentre Unit Sales]}
ON Columns, 
CrossJoin({Descendants([Time].[1997],2), Descendants([Time].[1998],2)}, 
 		{[Number_children_at_home].members} )
 		 ON ROWS
from [projetDW]



--##########################################################################
--Question 3 : 
WITH 
SET [Top Brands] AS
    TopCount(
        [Product].[Brand Name].Members, 
        5, 
        ([Measures].[Store Sales], [Product].[Product Family].[Food])
    )
SELECT 
    NON EMPTY 
        [Top Brands] ON ROWS,
    NON EMPTY 
        {
            [Measures].[Store Sales]
        } ON COLUMNS
FROM [projetDW]
WHERE (
    CrossJoin([Yearly Income].Members, 
    CrossJoin([Occupation].Members, 
    CrossJoin([Education].Members, [Number_children_at_home].Members)))
)

--##########################################################################
--Question 4 :
-- Yearly Income Query :

WITH
MEMBER [Measures].[Store Profit] AS '[Measures].[Store Sales] - [Measures].[Store Cost]'

SET Top5Brands AS
TopCount(
    Filter([Product].[Brand Name].Members, [Measures].[Store Profit] > 0),
    5,
    [Measures].[Store Profit]
)

SELECT
{
    [Measures].[Store Profit]
} ON COLUMNS,
Top5Brands ON ROWS
FROM [projetDW]
WHERE {[Time].[1997], [Time].[1998]} * [Yearly Income].Members

--Occupation Query :

WITH
MEMBER [Measures].[Store Profit] AS '[Measures].[Store Sales] - [Measures].[Store Cost]'

SET Top5Brands AS
TopCount(
    Filter([Product].[Brand Name].Members, [Measures].[Store Profit] > 0),
    5,
    [Measures].[Store Profit]
)

SELECT
{
    [Measures].[Store Profit]
} ON COLUMNS,
Top5Brands ON ROWS
FROM [projetDW]
WHERE {[Time].[1997], [Time].[1998]} * [Occupation].Members

--education

WITH
MEMBER [Measures].[Store Profit] AS '[Measures].[Store Sales] - [Measures].[Store Cost]'

SET Top5Brands AS
TopCount(
    Filter([Product].[Brand Name].Members, [Measures].[Store Profit] > 0),
    5,
    [Measures].[Store Profit]
)

SELECT
{
    [Measures].[Store Profit]
} ON COLUMNS,
Top5Brands ON ROWS
FROM [projetDW]
WHERE {[Time].[1997], [Time].[1998]} * [education].Members


--nombre d'enfant à la maison
WITH
MEMBER [Measures].[Store Profit] AS '[Measures].[Store Sales] - [Measures].[Store Cost]'

SET Top5Brands AS
TopCount(
    Filter([Product].[Brand Name].Members, [Measures].[Store Profit] > 0),
    5,
    [Measures].[Store Profit]
)

SELECT
{
    [Measures].[Store Profit]
} ON COLUMNS,
Top5Brands ON ROWS
FROM [projetDW]
WHERE {[Time].[1997], [Time].[1998]} * [Number_children_at_home].Members

-- les 4 parties regroupées dans une seule requete
WITH
MEMBER [Measures].[Store Profit] AS '[Measures].[Store Sales] - [Measures].[Store Cost]'

SET Top5Brands AS
TopCount(
    Filter([Product].[Brand Name].Members, [Measures].[Store Profit] > 0),
    5,
    [Measures].[Store Profit]
)

MEMBER [Time].[Yearly Income] AS Aggregate({[Time].[1997], [Time].[1998]} * [Yearly Income].Members)
MEMBER [Time].[Occupation] AS Aggregate({[Time].[1997], [Time].[1998]} * [Occupation].Members)
MEMBER [Time].[Education] AS Aggregate({[Time].[1997], [Time].[1998]} * [Education].Members)
MEMBER [Time].[Number_children_at_home] AS Aggregate({[Time].[1997], [Time].[1998]} * [Number_children_at_home].Members)

SELECT
{
    [Measures].[Store Profit]
} ON COLUMNS,
{
    Top5Brands
} ON ROWS
FROM [projetDW]
WHERE {
    [Time].[Yearly Income],
    [Time].[Occupation],
    [Time].[Education],
    [Time].[Number_children_at_home]

--##########################################################################
--Question 5 :

SELECT
{[Measures].[Unit Sales], [Measures].[Store Cost], [Measures].[Store Sales]} ON COLUMNS,
{[Product].[All Products].[Food].Children} ON ROWS
FROM [projetDW]
WHERE {[Number_children_at_home].[1] : [Number_children_at_home].[5]} 

--##############################################################################
--Question 6 : 

WITH 
SET [Top Categories] AS
    TopCount(
        [Product].[Product Category].Members, 
        3, 
        Sum([Product].[Product Category].CurrentMember.Children, [Measures].[Store Sales])
    )
MEMBER [Measures].[Average Sales Per Customer] AS
    [Measures].[Store Sales] / [Measures].[Unit Sales], 
    FORMAT_STRING = "Currency"
SELECT 
  NON EMPTY 
    {
      [Measures].[Store Sales],
      [Measures].[Unit Sales],
      [Measures].[Average Sales Per Customer]
    } ON COLUMNS,
  NON EMPTY 
    CrossJoin(
      [Top Categories],
      CrossJoin(
        [Yearly Income].Children,
        CrossJoin(
          [Education].Children,
          CrossJoin(
            [Number_children_at_home].Members,
            [Customers].[Country].Members
          )
        )
      )
    ) ON ROWS
FROM [projetDW]
WHERE (
    [Time].[Year].&[1998]  
)

-- d'autres relations clients identifiés
-- la ville qui consomme le plus d'alcool 
SELECT
  ORDER([Customers].[City].Members, [Measures].[Store Sales], BDESC).ITEM(0) ON COLUMNS,
  {[Measures].[Store Sales]} ON ROWS
FROM [projetDW]
WHERE [Product].[Drink].[Alcoholic Beverages]* {[Time].[1997], [Time].[1998]}

-- l'occupation qui consomme le plus d'alcool 
SELECT
  ORDER([Occupation].[Occupation].Members, [Measures].[Store Sales], BDESC).ITEM(0) ON COLUMNS,
  {[Measures].[Store Sales]} ON ROWS
FROM [projetDW]
WHERE [Product].[Drink].[Alcoholic Beverages] * {[Time].[1997], [Time].[1998]}

--l'occupation qui consomme le moins d'alcool est 
SELECT
  BOTTOMCOUNT([Occupation].[Occupation].Members, 1, [Measures].[Store Sales]) ON COLUMNS,
  {[Measures].[Store Sales]} ON ROWS
FROM [projetDW]
WHERE [Product].[Drink].[Alcoholic Beverages] * {[Time].[1997], [Time].[1998]}

-- les différentes occupations avec leurs ventes d'alcool respectives

SELECT
  {[Occupation].[Occupation].Members} ON COLUMNS,
  {[Measures].[Store Sales]} ON ROWS
FROM [projetDW]
WHERE [Product].[Drink].[Alcoholic Beverages] * {[Time].[1997], [Time].[1998]}
