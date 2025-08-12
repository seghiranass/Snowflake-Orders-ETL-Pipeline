select 
    ORDERKEY,
    sum(extended_price) as gross_item_sales_amount,
    sum(item_discount_amount) as item_discount_amount
FROM
    {{ ref('int_order_items') }}
group by
    orderkey
