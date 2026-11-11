-- Calculates the Year-over-Year spending ratio for FDA shortage events vs. Control group
WITH cte_yoy AS (
    SELECT generic_clean, year, total_spending,
           LAG(total_spending) OVER (PARTITION BY generic_clean ORDER BY year) AS prev_spending
    FROM cms_spending_long
)
SELECT y.generic_clean, y.year,
       CAST(y.total_spending AS FLOAT) / NULLIF(y.prev_spending, 0) AS spending_ratio,
       CASE WHEN e.generic_clean IS NOT NULL THEN 'Shortage' ELSE 'Control' END AS group_type
FROM cte_yoy y
LEFT JOIN fda_shortage_events e ON y.generic_clean = e.generic_clean AND y.year = e.event_year
WHERE y.prev_spending > 0;
