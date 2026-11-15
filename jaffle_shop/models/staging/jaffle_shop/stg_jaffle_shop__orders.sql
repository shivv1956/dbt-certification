SELECT 
    id AS order_id,
    user_id AS customer_id,
    order_date,
    status,
    case
        when status not in ('returned', 'pending') then order_date
    end AS valid_order_date
 FROM {{ source('jaffle_shop', 'orders') }}