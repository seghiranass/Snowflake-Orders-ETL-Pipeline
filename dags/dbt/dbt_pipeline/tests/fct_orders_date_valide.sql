select
    *
from
    {{ ref('fct_orders') }}
where
    date(ORDERDATE) > CURRENT_DATE()
    or date(ORDERDATE) < date('1990-01-01')