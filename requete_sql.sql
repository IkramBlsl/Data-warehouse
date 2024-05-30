--Question 1 : 

Product Family :

SELECT 
    pc.product_family, 
    c.yearly_income,
    c.occupation,
    c.num_children_at_home,
    SUM(s.store_sales) AS TotalSales,
    (SUM(s.store_sales) / SUM(SUM(s.store_sales)) OVER (PARTITION BY pc.product_family)) * 100 AS PercentageOfSales
FROM 
    sales_fact_projetDW s
JOIN 
    product p ON s.product_id = p.product_id
JOIN 
    product_class pc ON p.product_class_id = pc.product_class_id
JOIN 
    customer c ON s.customer_id = c.customer_id
GROUP BY 
    pc.product_family, 
    c.yearly_income,
    c.occupation,
    c.num_children_at_home;

--##########################################################################################
--Product Category : 

SELECT 
    pc.product_category, 
    c.yearly_income,
    c.occupation,
    c.num_children_at_home,
    SUM(s.store_sales) AS TotalSales,
    (SUM(s.store_sales) / SUM(SUM(s.store_sales)) OVER (PARTITION BY pc.product_category)) * 100 AS PercentageOfSales
FROM 
    sales_fact_projetDW s
JOIN 
    product p ON s.product_id = p.product_id
JOIN 
    product_class pc ON p.product_class_id = pc.product_class_id
JOIN 
    customer c ON s.customer_id = c.customer_id
GROUP BY 
    pc.product_category, 
    c.yearly_income,
    c.occupation,
    c.num_children_at_home;

--###################################################################################################
--Question 2:
SELECT
    product_family,
    yearly_income,
    occupation,
    num_children_at_home,
    SUM(MoyenMobileCentreStoreSales) AS TotalMoyenMobileCentreStoreSales,
    SUM(MoyenMobileCentreStoreCost) AS TotalMoyenMobileCentreStoreCost,
    SUM(MoyenMobileCentreUnitSales) AS TotalMoyenMobileCentreUnitSales
FROM (
    SELECT
        s.time_id,
        pc.product_family,
        c.yearly_income,
        c.occupation,
        c.num_children_at_home,
        AVG(s.store_sales) OVER (PARTITION BY pc.product_family, c.yearly_income, c.occupation, c.num_children_at_home ORDER BY s.time_id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS MoyenMobileCentreStoreSales,
        AVG(s.store_cost) OVER (PARTITION BY pc.product_family, c.yearly_income, c.occupation, c.num_children_at_home ORDER BY s.time_id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS MoyenMobileCentreStoreCost,
        AVG(s.unit_sales) OVER (PARTITION BY pc.product_family, c.yearly_income, c.occupation, c.num_children_at_home ORDER BY s.time_id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS MoyenMobileCentreUnitSales
    FROM
        sales_fact_projetDW s
    JOIN
        product p ON s.product_id = p.product_id
    JOIN
        product_class pc ON p.product_class_id = pc.product_class_id
    JOIN
        customer c ON s.customer_id = c.customer_id
    WHERE
        s.time_id IN (SELECT time_id FROM time_by_day WHERE the_year IN (1997, 1998))
) AS MoyenMobileCentre
GROUP BY
    product_family,
    yearly_income,
    occupation,
    num_children_at_home;

--###################################################################################################
--Question 3 : 

WITH ranked_brands AS (
    SELECT
        p.product_category,
        d.brand_name,
        c.yearly_income,
        c.occupation,
        c.education,
        c.num_children_at_home,
        f.store_sales,
        ROW_NUMBER() OVER (PARTITION BY p.product_category, c.yearly_income, c.occupation, c.education, c.num_children_at_home ORDER BY f.store_sales DESC) AS brand_rank
    FROM
        sales_fact_projetdw f
    INNER JOIN
        product_class p ON f.product_id = p.product_class_id
    INNER JOIN
        customer c ON f.customer_id = c.customer_id
    INNER JOIN
        product d ON d.product_class_id = p.product_class_id
    WHERE
        p.product_family = 'food'
)
SELECT
    product_category,
    yearly_income,
    occupation,
    education,
    num_children_at_home,
    brand_name,
    store_sales
FROM
    ranked_brands
WHERE
    brand_rank <= 5
limit 10;
--#################################################################################################
--Question 4:

SELECT
    pc.product_category,
    c.yearly_income,
    c.occupation,
    c.education,
    c.num_children_at_home,
    p.brand_name,
    SUM(s.store_sales - s.store_cost) AS Profit
FROM
    sales_fact_projetDW s
JOIN
    product p ON s.product_id = p.product_id
JOIN
    product_class pc ON p.product_class_id = pc.product_class_id
JOIN
    customer c ON s.customer_id = c.customer_id
WHERE
    pc.product_family = 'Food' -- Filtrer par famille de produits (nourritures)
    AND s.time_id IN (SELECT time_id FROM time_by_day WHERE the_year IN (1997, 1998)) -- Filtre par année
GROUP BY
    pc.product_category,
    c.yearly_income,
    c.occupation,
    c.education,
    c.num_children_at_home,
    p.brand_name
ORDER BY
    Profit DESC
LIMIT 5; -- Sélectionner les 5 premières marques avec les plus grands bénéfices

--#################################################################################################
--Question 5 :

SELECT
    num_children_at_home,
    AVG(store_cost) AS avg_store_cost
FROM
    sales_fact_projetdw f
INNER JOIN
    customer c ON f.customer_id = c.customer_id
INNER JOIN
    product_class p ON f.product_id = p.product_class_id
WHERE
    p.product_family = 'food'
GROUP BY
    num_children_at_home
limit 10;

--###################################################################################################
--Question 6 :

WITH TopCategories AS (
    SELECT pc.product_category
    FROM sales_fact_projetDW s
    JOIN product p ON s.product_id = p.product_id
    JOIN product_class pc ON p.product_class_id = pc.product_class_id
    GROUP BY pc.product_category
    ORDER BY SUM(s.store_sales) DESC
    LIMIT 3
),
AverageSalesPerCustomer AS (
    SELECT 
        pc.product_category,
        c.yearly_income,
        c.education,
        c.num_children_at_home,
        c.country,
        SUM(s.store_sales) AS TotalStoreSales,
        SUM(s.unit_sales) AS TotalUnitSales,
        SUM(s.store_sales) / SUM(s.unit_sales) AS AvgSalesPerCustomer
    FROM sales_fact_projetDW s
    JOIN customer c ON s.customer_id = c.customer_id
    JOIN product p ON s.product_id = p.product_id
    JOIN product_class pc ON p.product_class_id = pc.product_class_id
    JOIN time_by_day t ON s.time_id = t.time_id
    WHERE t.the_year = 1998
    GROUP BY 
        pc.product_category,
        c.yearly_income,
        c.education,
        c.num_children_at_home,
        c.country
)
SELECT 
    a.TotalStoreSales,
    a.TotalUnitSales,
    a.AvgSalesPerCustomer,
    a.product_category,
    a.yearly_income,
    a.education,
    a.num_children_at_home,
    a.country
FROM AverageSalesPerCustomer a
WHERE a.product_category IN (SELECT product_category FROM TopCategories)
ORDER BY a.product_category, a.yearly_income, a.education, a.num_children_at_home, a.country;





