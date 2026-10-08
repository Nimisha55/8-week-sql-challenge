# Case Study #1: Danny's Diner 🍜

## Business Problem

Danny's Diner wants to better understand customer purchasing
behavior, spending patterns, menu preferences, and loyalty
program activity.

## Dataset

The analysis uses three datasets:

- `sales`
- `menu`
- `members`

## Entity Relationship Diagram

The Danny's Diner dataset consists of three tables: `sales`, `menu`, and `members`.

![Danny's Diner Entity Relationship Diagram](images/dannys-diner-erd.png)

## Data Exploration

Initial exploration of the dataset revealed:

- 15 sales records across 3 customers.
- 3 menu items: sushi, curry, and ramen.
- 2 customers enrolled in the loyalty program.
- Transactions spanning January 1 to February 1, 2021.
- No missing values in the sales dataset.

The complete exploratory SQL queries are available
in `exploration.sql`.

## Questions & Solutions

### Question 1: What is the total amount each customer spent at the restaurant?

#### Approach

Joined the `sales` and `menu` tables using `product_id` to retrieve the price of each purchased item. Used `SUM()` to calculate total spending and `GROUP BY` to aggregate the results for each customer.

#### SQL Query

```sql
SELECT
    s.customer_id,
    SUM(m.price) AS total_spent
FROM sales AS s
JOIN menu AS m
    ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;
```

#### Query Results

| customer | total_amount |
| -------- | ------------ |
| A        | 76           |
| B        | 74           |
| C        | 36           |

#### Key Insights

- Customer A generated the highest revenue at **$76**.
- Customer B followed closely with **$74** in spending.
- Customer C spent **$36**, the lowest among the three customers.
- Customers A and B together contributed **$150** in revenue, representing approximately **81% of total sales**.

---

### Question 2: How many days has each customer visited the restaurant?

#### Approach

Used `COUNT(DISTINCT order_date)` to calculate the number of unique days each customer visited Danny's Diner. The `DISTINCT` keyword ensures that multiple purchases made on the same day are counted as a single visit.

#### SQL Query

```sql
SELECT
    customer_id,
    COUNT(DISTINCT order_date) AS total_visits
FROM sales
GROUP BY customer_id
ORDER BY customer_id;
```

#### Query Results

| customer | days_each_customer_visited |
| -------- | -------------------------- |
| A        | 4                          |
| B        | 6                          |
| C        | 2                          |

#### Key Insights

- **Customer A** visited the restaurant on 4 different days.
- **Customer B** visited on 6 different days, making them the most frequent visitor.
- **Customer C** visited on only 2 different days.
- Although Customer A spent the most overall, Customer B visited more frequently, highlighting the difference between customer spending and visit frequency.

---

### Question 3: What was the first item from the menu purchased by each customer?

#### Approach

Used a **self-join** on the `sales` table to identify each customer's earliest purchase. A `LEFT JOIN` compares each transaction against earlier transactions by the same customer, while `WHERE s2.customer_id IS NULL` filters for purchases with no earlier order.

Joined the `menu` table to retrieve product names and used `DISTINCT` to eliminate duplicate items purchased on the first visit.

#### SQL Query

```sql
SELECT DISTINCT
    s.customer_id,
    m.product_name
FROM sales AS s
LEFT JOIN sales AS s2
    ON s.customer_id = s2.customer_id
    AND s2.order_date < s.order_date
JOIN menu AS m
    ON s.product_id = m.product_id
WHERE s2.customer_id IS NULL
ORDER BY s.customer_id, m.product_name;
```

#### Query Results

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

#### Key Insights

- **Customer A** purchased both curry and sushi on their first visit.
- **Customer B** purchased curry on their first visit.
- **Customer C** purchased ramen on their first visit.
- All three menu items were represented among customers' first purchases, indicating varied initial preferences.

---

### Question 4: What is the most purchased item on the menu, and how many times was it purchased by all customers?

#### Approach

Joined the `sales` and `menu` tables using `product_id` to identify purchased menu items. Used `COUNT(*)` to calculate the total number of purchases for each item and `GROUP BY` to aggregate the results. Sorted the purchase counts in descending order and used `LIMIT 1` to identify the most frequently purchased item.

#### SQL Query

```sql
SELECT
    m.product_name,
    COUNT(*) AS total_purchases
FROM sales AS s
JOIN menu AS m
    ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY total_purchases DESC
LIMIT 1;
```

#### Query Results

| product_name | total_purchases |
| ------------ | --------------- |
| ramen        | 8               |

#### Key Insights

- **Ramen** was the most frequently purchased menu item, with **8 purchases**.
- Ramen accounted for approximately **53.3% of all 15 purchases**.
- Its popularity suggests that ramen is an important menu item for Danny's Diner and could be featured in promotional campaigns.

---

### Question 5: Which item was the most popular for each customer?

#### Approach

Joined the `sales` and `menu` tables using `product_id` to identify each customer's purchases. Used `COUNT(*)` and `GROUP BY` to calculate the purchase frequency of each menu item for every customer.

The results were sorted by customer and purchase frequency in descending order to identify the most frequently purchased items, including ties.

#### SQL Query

```sql
SELECT
    s.customer_id,
    m.product_name,
    COUNT(*) AS total_purchases
FROM sales AS s
JOIN menu AS m
    ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
ORDER BY s.customer_id, total_purchases DESC;
```

#### Query Results

| customer_id | product_name | total_purchases |
| ----------- | ------------ | --------------- |
| A           | ramen        | 3               |
| A           | curry        | 2               |
| A           | sushi        | 1               |
| B           | ramen        | 2               |
| B           | curry        | 2               |
| B           | sushi        | 2               |
| C           | ramen        | 3               |

#### Key Insights

- **Customer A:** Ramen was the most popular item, purchased 3 times.
- **Customer B:** Curry, ramen, and sushi were equally popular, with 2 purchases each.
- **Customer C:** Ramen was the only item purchased, with 3 purchases.
- **Overall:** Ramen was a top preference for all three customers, suggesting it could be a strong focus for promotions and loyalty rewards.

**Note:** This query displays all customer-item purchase counts rather than filtering automatically to only the most popular items. The highest count for each customer is identified from the sorted results.

---


### Question 6: Which item was purchased first by the customer after they became a member?

#### Approach

Joined the `sales`, `members`, and `menu` tables to analyze purchases made after customers joined the loyalty program.

Filtered transactions using `order_date >= join_date` to include purchases made on or after the membership date. Used `MIN()` and `GROUP BY` to identify the earliest purchase date for each product, then sorted the results chronologically to identify each customer's first purchase.

#### SQL Query

```sql
SELECT
    s.customer_id,
    m.product_name,
    MIN(s.order_date) AS purchase_date
FROM sales AS s
JOIN members AS mb
    ON s.customer_id = mb.customer_id
JOIN menu AS m
    ON s.product_id = m.product_id
WHERE s.order_date >= mb.join_date
GROUP BY s.customer_id, m.product_name
ORDER BY s.customer_id, purchase_date;
```

#### Query Results

| customer_id | product_name | purchase_date |
| ----------- | ------------ | ------------- |
| A           | curry        | 2021-01-07    |
| A           | ramen        | 2021-01-10    |
| B           | sushi        | 2021-01-11    |
| B           | ramen        | 2021-01-16    |

#### Key Insights

- **Customer A:** Curry was the first item purchased after joining the loyalty program on January 7, 2021.
- **Customer B:** Sushi was the first item purchased after joining on January 9, 2021, with the purchase occurring on January 11.
- **Customer C:** Was not enrolled in the loyalty program and is therefore excluded.

**Note:** The query lists each customer's earliest purchase of each product after membership. The first chronological result for each customer identifies their first post-membership item.

---

### Question 7: Which item was purchased just before the customer became a member?

#### Approach

Joined the `sales`, `members`, and `menu` tables to identify purchases made before customers joined the loyalty program.

Used a self-join with `LEFT JOIN` to check whether a later pre-membership purchase existed for each transaction. Filtered using `IS NULL` to retain purchases made on the last visit before membership, including multiple items purchased on the same date.

#### SQL Query

```sql
SELECT DISTINCT
    s.customer_id,
    m.product_name,
    s.order_date
FROM sales AS s
JOIN members AS mb
    ON s.customer_id = mb.customer_id
JOIN menu AS m
    ON s.product_id = m.product_id
LEFT JOIN sales AS s2
    ON s.customer_id = s2.customer_id
    AND s2.order_date < mb.join_date
    AND s2.order_date > s.order_date
WHERE s.order_date < mb.join_date
    AND s2.customer_id IS NULL
ORDER BY s.customer_id, m.product_name;
```

#### Query Results

| customer_id | product_name | order_date |
| ----------- | ------------ | ---------- |
| A           | curry        | 2021-01-01 |
| A           | sushi        | 2021-01-01 |
| B           | sushi        | 2021-01-04 |

#### Key Insights

- **Customer A:** Purchased curry and sushi on January 1, 2021, before joining the loyalty program on January 7.
- **Customer B:** Purchased sushi on January 4, 2021, before joining on January 9.
- **Customer C:** Was excluded because they were not enrolled in the loyalty program.
- Both members had purchased sushi before joining, suggesting it was a common pre-membership purchase in this small sample.

---

### Question 8: What is the total number of items and amount spent for each member before they became a member?

#### Approach

Joined the `sales`, `members`, and `menu` tables to analyze customer purchases before loyalty program enrollment.

Filtered transactions using `order_date < join_date` to exclude purchases made on or after the membership date. Used `COUNT()` to calculate the number of items purchased and `SUM()` to calculate total spending for each member.

#### SQL Query

```sql
SELECT
    s.customer_id,
    COUNT(s.product_id) AS total_items,
    SUM(m.price) AS total_spent
FROM sales AS s
JOIN members AS mb
    ON s.customer_id = mb.customer_id
JOIN menu AS m
    ON s.product_id = m.product_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;
```

#### Query Results

| customer_id | total_items | total_spent |
| ----------- | ----------- | ----------- |
| A           | 2           | 25          |
| B           | 3           | 40          |

#### Key Insights

- **Customer A:** Purchased 2 items and spent $25 before joining the loyalty program.
- **Customer B:** Purchased 3 items and spent $40 before becoming a member.
- **Customer B** spent $15 more than Customer A before enrollment.
- These results provide a baseline for comparing purchasing behavior before and after loyalty program enrollment.

---

### Question 9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier, how many points would each customer have?

#### Approach

Joined the `sales` and `menu` tables to calculate loyalty points based on each purchased item's price.

Used `CASE WHEN` to apply a 2x points multiplier for sushi (20 points per dollar), while all other menu items earned 10 points per dollar. Aggregated the points using `SUM()` for each customer.

#### SQL Query

```sql
SELECT
    s.customer_id,
    SUM(
        CASE
            WHEN m.product_name = 'sushi'
                THEN m.price * 20
            ELSE m.price * 10
        END
    ) AS total_points
FROM sales AS s
JOIN menu AS m
    ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;
```

#### Query Results

| customer_id | total_points |
| ----------- | ------------ |
| A           | 860          |
| B           | 940          |
| C           | 360          |

#### Key Insights

- **Customer B** earned the highest number of points (940), despite Customer A having the highest total spending.
- **Customer A** earned 860 points, while Customer C earned 360 points.
- Customer B benefited more from the sushi multiplier because they purchased sushi more frequently.
- The bonus points system rewards specific purchasing behavior rather than simply total spending.

---

### Question 10: How many points do Customer A and B have at the end of January?

#### Approach

Joined the `sales`, `members`, and `menu` tables to calculate loyalty points earned through January 31, 2021.

Used `CASE WHEN` to apply the following rules:

- Customers earn 10 points per dollar spent.
- Sushi earns 2x points (20 points per dollar).
- During the first 7 days of membership, all menu items earn 2x points.
- The promotional period includes the membership joining date.
- Only transactions through January 31, 2021 are included.

#### SQL Query

```sql
SELECT
    s.customer_id,
    SUM(
        CASE
            WHEN s.order_date BETWEEN mb.join_date
                AND mb.join_date + INTERVAL '6 days'
                THEN m.price * 20
            WHEN m.product_name = 'sushi'
                THEN m.price * 20
            ELSE m.price * 10
        END
    ) AS total_points
FROM sales AS s
JOIN members AS mb
    ON s.customer_id = mb.customer_id
JOIN menu AS m
    ON s.product_id = m.product_id
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id
ORDER BY s.customer_id;
```

#### Query Results

| customer_id | total_points |
| ----------- | ------------ |
| A           | 1370         |
| B           | 820          |

#### Key Insights

- **Customer A** earned 1,370 points by the end of January.
- **Customer B** earned 820 points during the same period.
- Customer A benefited from multiple purchases during the first-week double-points promotion.
- The promotional structure encourages purchasing activity immediately after loyalty program enrollment.

---

