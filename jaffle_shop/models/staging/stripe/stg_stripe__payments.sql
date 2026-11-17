with source as (
    select * from {{ ref('payments_snapshot') }}
    -- keep only the current version of each payment
    where {{ snapshot_is_current() }}
),

transformed as (
    select
        id as payments_id,
        orderid as order_id,
        paymentmethod as payment_method,
        status as payment_status,
        amount / 100 as payment_amount,
        created as payment_created_at,
        _batched_at as insert_timestamp
    from source
)

select * from transformed
