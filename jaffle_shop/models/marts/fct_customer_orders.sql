{{
    config(
        materialized = 'incremental'
    )
}}

with

customers as (

    select * from {{ ref('stg_jaffle_shop__customers') }}

),

orders as (

    select * from {{ ref('int_orders') }}

),

customer_orders as (

    select
        orders.*,
        customers.givenname as customer_first_name,
        customers.surname as customer_last_name,

        -- sales sequences
        row_number() over (
            order by orders.order_placed_at, orders.order_id
        ) as transaction_seq,

        row_number() over (
            partition by orders.customer_id
            order by orders.order_placed_at, orders.order_id
        ) as customer_sales_seq,

        rank() over (
            partition by orders.customer_id
            order by orders.order_placed_at, orders.order_id
        ) as customer_order_rank,

        -- running lifetime value (legacy customer_lifetime_value)
        sum(orders.total_amount_paid) over (
            partition by orders.customer_id
            order by orders.order_placed_at, orders.order_id
        ) as running_lifetime_value,

        -- customer-level aggregates
        min(orders.order_placed_at) over (
            partition by orders.customer_id
        ) as first_order_date,

        min(orders.valid_order_date) over (
            partition by orders.customer_id
        ) as first_non_returned_order_date,

        max(orders.valid_order_date) over (
            partition by orders.customer_id
        ) as most_recent_non_returned_order_date,

        count(*) over (
            partition by orders.customer_id
        ) as order_count,

        sum(nvl2(orders.valid_order_date, 1, 0)) over (
            partition by orders.customer_id
        ) as non_returned_order_count,

        sum(nvl2(orders.valid_order_date, orders.total_amount_paid, 0)) over (
            partition by orders.customer_id
        ) as total_lifetime_value

    from orders
    inner join customers on orders.customer_id = customers.customer_id

),

add_avg_order_values as (

    select
        *,
        total_lifetime_value / nullif(non_returned_order_count, 0) as avg_non_returned_order_value
    from customer_orders

),

-- audit: column names match the legacy model's final output
final as (

    select
        order_id,
        customer_id,
        order_placed_at,
        order_status,
        total_amount_paid,
        payment_finalized_date,
        customer_first_name,
        customer_last_name,
        transaction_seq,
        customer_sales_seq,
        case when customer_order_rank = 1 then 'new' else 'return' end as nvsr,
        running_lifetime_value as customer_lifetime_value,
        first_order_date as fdos
    from add_avg_order_values

)

select * from final
{% if is_incremental() %}
    where order_placed_at > (select max(order_placed_at) from {{this}})
{% endif %}
order by order_placed_at desc