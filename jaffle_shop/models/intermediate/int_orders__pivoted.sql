
{%- set payment_methods = ['bank_transfer','coupon','gift_card','credit_card'] -%}
with payments as (
    select * from {{ ref('stg_stripe__payments') }}
    where payment_status = 'success'
),
pivoted as (
    select order_id,
        
        {%- for method in payment_methods %}
        sum( case when payment_method = '{{method}}' then payment_amount else 0 end) as {{method}}_amount
        {%- if not loop.last -%} ,{%- endif -%}
        
        {%- endfor -%}

        ,{{ cents_to_dollars('sum(payment_amount)',2) }} as total_amount
    from payments 
    group by 1
)
select * from pivoted