select 
    orders.*,
    order_item_summary.gross_item_sales_amount as item_sales_amount,
    order_item_summary.item_discount_amount as item_discount_amount

from 
    {{ ref('stg_tpch_orders') }} as orders
join
    {{ ref('int_order_items_summary') }} as  order_item_summary
on
    orders.ORDERKEY = order_item_summary.ORDERKEY
order by
    ORDERDATE