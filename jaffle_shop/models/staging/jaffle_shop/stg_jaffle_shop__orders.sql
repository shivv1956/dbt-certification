with source as (
    select * from {{ ref('orders_snapshot') }}
    -- keep only the current version of each order
    where {{ snapshot_is_current() }}
),

transformed as (
    select
        id as order_id,
        user_id as customer_id,
        order_date,
        status,
        case
            when status not in ('returned', 'return_pending') then order_date
        end as valid_order_date
    from source
)

select * from transformed
