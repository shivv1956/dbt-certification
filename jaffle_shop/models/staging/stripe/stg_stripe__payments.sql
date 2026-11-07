SELECT 
    id as payments_id,
    orderid as order_id,
    paymentmethod as payment_method,
    status,
    amount / 100 AS amount,
    created as created_date,
    _batched_at as insert_timestamp
    FROM {{ source('stripe', 'payments') }}