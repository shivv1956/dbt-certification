import holidays
import pandas 
def model(dbt,session):
    dbt.config(
        materialized = "table",
        packages=['pandas','pyarrow','holidays']
    )

    us_holidays = holidays.US()
    df = dbt.ref('date_spine').to_pandas()
    df['IS_HOLIDAY'] = df['DATE_DAY'].apply(lambda x: x in us_holidays)
    return df