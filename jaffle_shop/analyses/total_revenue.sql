with payments as (
    select * from {{ ref('stg_stripe__payments') }}
),
calculated as (
    select payment_created_at as payment_date,
  
    sum(
        case when payment_status = 'success' then payment_amount else 0 end
    ) as total_payments
    from payments 
    group by 1
)
select * from calculated
order by payment_date