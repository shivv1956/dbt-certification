with source as (
    select * from {{ ref('customers_snapshot') }}
    -- keep only the current version of each customer
    where {{ snapshot_is_current() }}
),

transformed as (
    select
        id as customer_id,
        last_name as surname,
        first_name as givenname,
        first_name || ' ' || last_name as full_name
    from source
)

select * from transformed
