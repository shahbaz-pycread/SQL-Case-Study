/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, SUM(me.price) total_amount_spent
    FROM dannys_diner..sales s
    JOIN dannys_diner..menu me ON s.product_id = me.product_id
    GROUP BY s.customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(order_date) Total_Visits
    FROM dannys_diner..sales
    GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

SELECT s.customer_id, s.order_date, m.product_name
    FROM dannys_diner..sales s
    JOIN dannys_diner..menu m on s.product_id = m.product_id
    WHERE s.order_date = '2021-01-01'
    ORDER BY s.order_date;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.product_name, COUNT(s.product_id) Total_Purchased
    FROM dannys_diner..menu m
    JOIN dannys_diner..sales s on m.product_id = s.product_id
    GROUP BY m.product_name
    ORDER BY Total_Purchased DESC;

-- 5. Which item was the most popular for each customer?

with cte AS(
    SELECT s.customer_id, m.product_name, COUNT(*) Total_Order,
    dense_rank() OVER(partition by s.customer_id ORDER BY count(s.customer_id) DESC) as rank
    FROM dannys_diner..sales s 
    JOIN dannys_diner..menu m 
    on s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name)

SELECT customer_id, product_name, total_order 
    FROM  cte
    where rank = 1;

)
-- 6. Which item was purchased first by the customer after they became a member?

SELECT r.* , m.product_name from
 (SELECT row_number()over(partition by s.customer_id order by order_date) as row_num ,s.customer_id, s.product_id,s.order_date, mr.join_date from dannys_diner..sales s
 join dannys_diner..members mr
 on s.customer_id=mr.customer_id
 where s.order_date>=mr.join_date) r
 join dannys_diner..menu m
 on r.product_id=m.product_id
 where row_num=1
 
-- 7. Which item was purchased just before the customer became a member?

SELECT ra.* , m.product_name from
 (SELECT rank()over(partition by s.customer_id order by order_date desc) as rank_num ,s.customer_id, s.product_id,s.order_date, mr.join_date from dannys_diner..sales s
 join dannys_diner..members mr
 on s.customer_id=mr.customer_id
 where s.order_date<mr.join_date) ra
 join dannys_diner..menu m
 on ra.product_id=m.product_id
 where rank_num=1

 

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, COUNT(DISTINCT m.product_id) Total_items, SUM(m.price) Amount_Spent
    FROM dannys_diner..sales s 
    JOIN dannys_diner..menu m ON s.product_id = m.product_id
    JOIN dannys_diner..members mr on s.customer_id = mr.customer_id
    WHERE s.order_date < mr.join_date
    GROUP BY s.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT s.customer_id,
    SUM(
        CASE
            WHEN m.product_name = 'sushi' THEN m.price * 20 ELSE m.price * 10
        END ) Total_Points
    FROM dannys_diner..sales s
    JOIN dannys_diner..menu m on s.product_id = m.product_id
    GROUP BY s.customer_id
    ORDER BY s.customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT s.customer_id,
SUM(
    CASE WHEN  s.order_date >= mr.join_date AND s.order_date <= DATEADD(day,7,mr.join_date) then m.price * 20 ELSE
    (
        CASE WHEN s.product_id=1 THEN m.price * 20 ELSE m.price * 10
        END
    )
    End
) Total_Points
    FROM dannys_diner..sales s
    JOIN dannys_diner..members mr ON s.customer_id = mr.customer_id
    JOIN dannys_diner..menu m on s.product_id = m.product_id
WHERE s.order_date BETWEEN '2021-01-01' AND '2021-01-31'
GROUP BY s.customer_id;

