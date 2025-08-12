select 
    items.order_item_key,
    items.part_key,
    items.line_number,
    items.extended_price,
    orders.ORDERKEY,
    orders.CUSTKEY,
    orders.ORDERDATE,
    {{ discounted_amount('items.extended_price', 'items.discount_percentage') }} as item_discount_amount

from {{ ref('stg_tpch_orders') }} as orders
join {{ ref('stg_tpch_lineitem') }} as items
on orders.ORDERKEY = items.order_key
order by orders.ORDERDATE