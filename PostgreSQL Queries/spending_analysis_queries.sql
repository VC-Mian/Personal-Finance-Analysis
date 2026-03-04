-- Query 1: How much did I actually spend in addition to the cashback
SELECT 
    year,
    TRIM(month_name) as month,
    
    -- How many purchases made in each month
    COUNT(*) FILTER (WHERE debit > 0) as num_purchases,
    
    -- Total spent that month (before cashback)
    ROUND(SUM(debit), 2) as total_spent,
    
    -- Total cashback earned in each month
    ROUND(ABS(SUM(COALESCE(cashback, 0))), 2) as total_cashback,
    
    -- What I actually paid (debit - cashback)
    ROUND(SUM(debit) + SUM(COALESCE(cashback, 0)), 2) as net_paid

FROM transactions
GROUP BY year, month_name
ORDER BY year, TO_DATE(month_name, 'Month'); 


-- Query 2: Where do I spend the most?
SELECT 
    category,
    
    -- How many transactions in this category
    COUNT(*) as num_transactions,
    
    -- Total spent in this category
    ROUND(SUM(debit), 2) as total_spent,
    
    -- Average transaction size
    ROUND(AVG(debit), 2) as avg_transaction,
    
    -- Smallest and largest purchases
    ROUND(MIN(debit), 2) as smallest_purchase,
    ROUND(MAX(debit), 2) as largest_purchase,
    
    -- What percentage of total spending is this category?
    ROUND(
        (SUM(debit) / (SELECT SUM(debit) FROM transactions WHERE debit > 0 AND category != 'Payment/Credit')) * 100, 
        2
    ) as pct_of_total

FROM transactions
WHERE debit > 0  
  AND category != 'Payment/Credit' 

GROUP BY category
ORDER BY total_spent DESC; 

SELECT DISTINCT description
FROM transactions
WHERE debit > 0
ORDER BY description;

-- Query 3: Top 20 Merchants
SELECT 
    CASE
        -- Group all Amazon
        WHEN description LIKE '%AMAZON%' OR description LIKE '%Amazon.com%' THEN 'Amazon'
        
        -- Group all eBay 
        WHEN description LIKE '%eBay%' THEN 'eBay'
        
        -- Group Walmart
        WHEN description LIKE '%WAL-MART%' THEN 'Walmart'
        
        -- Group Shell
        WHEN description LIKE '%SHELL%' THEN 'Shell'
        
        -- Group Food Lion
        WHEN description LIKE '%FOOD LION%' THEN 'Food Lion'
        
        -- Group Five Below
        WHEN description LIKE '%FIVE BELOW%' THEN 'Five Below'
        
        -- Duke Energy
        WHEN description LIKE '%DUKE%' THEN 'Duke Energy'
        
        -- TEMU
        WHEN description LIKE '%TEMU%' THEN 'TEMU'
        
        -- GeekJack
        WHEN description LIKE '%GEEKJACK%' THEN 'GeekJack'
        
        -- Microsoft
        WHEN description LIKE '%Microsoft%' OR description LIKE '%MICROSOFT%' THEN 'Microsoft'
        
        ELSE description
    END as merchant,
    
    -- total spent
    ROUND(SUM(debit), 2) as total_spent

FROM transactions
WHERE debit > 0 
  AND category != 'Payment/Credit'

GROUP BY merchant
ORDER BY total_spent DESC  
LIMIT 20;

-- Query 4: Which day of week do I spend the most?
SELECT 
    TRIM(day_of_week) as day,
    
    -- Number of purchases
    COUNT(*) as num_transactions,
    
    -- Total spent on this day
    ROUND(SUM(debit), 2) as total_spent,
    
    -- Average transaction size
    ROUND(AVG(debit), 2) as avg_spending

FROM transactions
WHERE debit > 0  
  AND category != 'Payment/Credit' 

GROUP BY TRIM(day_of_week)
ORDER BY total_spent DESC;  

