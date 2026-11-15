SELECT 
    id as payments_id,
    orderid as order_id,
    paymentmethod as payment_method,
    status AS payment_status,
    amount / 100 AS payment_amount,
    created as payment_created_at,
    _batched_at as insert_timestamp
    FROM {{ source('stripe', 'payments') }}