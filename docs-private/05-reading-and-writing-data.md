# Reading and writing data using Unity SDK

**unity_sdk** provides a set of decorators and functions to read and write data.

## Reading Data
To read data from **Unity DB**, you can use the `TSClient` class. Here's a simple example of how to read data:

```python
from unity_sdk.clients import TSClient
from unity_sdk.engine.config import get_secret
# get token from secrets manager
token = get_secret('RAW_DB_TOKEN')
# specify the database name
db = "Raw"

with TSClient(token=token, database=db) as client:
    query = """SELECT *
            FROM "water_quality_lab_measurements_v2"
            limit 100"""
    table = client.read(query, mode="all")
    # Convert the table to a pandas DataFrame
    df = table.to_pandas()
```
Now you can use the DataFrame `df` as needed

!!! note "Supported SQL Keywords"

    You can use the following SQL keywords in your queries:
        <table>
          <tr>
            <td>AND</td>
            <td>ALL</td>
            <td>ANALYZE</td>
            <td>AS</td>
            <td>ASC</td>
            <td>AT TIME ZONE</td>
          </tr>
          <tr>
            <td>BETWEEN</td>
            <td>BOTTOM</td>
            <td>CASE</td>
            <td>DESC</td>
            <td>DISTINCT</td>
            <td>EXISTS</td>
          </tr>
          <tr>
            <td>EXPLAIN</td>
            <td>FROM</td>
            <td>GROUP BY</td>
            <td>HAVING</td>
            <td>IN</td>
            <td>INNER JOIN</td>
          </tr>
          <tr>
            <td>JOIN</td>
            <td>LEFT JOIN</td>
            <td>LIKE</td>
            <td>LIMIT</td>
            <td>NOT</td>
            <td>EXISTS</td>
          </tr>
          <tr>
            <td>NOT IN</td>
            <td>OR</td>
            <td>ORDER BY</td>
            <td>FULL OUTER JOIN</td>
            <td>RIGHT JOIN</td>
            <td>SELECT</td>
          </tr>
          <tr>
            <td>TOP</td>
            <td>TYPE</td>
            <td>UNION</td>
            <td>UNION ALL</td>
            <td>WHERE</td>
            <td>WITH</td>
          </tr>
        </table>
---

## Writing Data
To write data to **Unity DB**, you can use the `TSClient` class as well. Here's an example of how to write a DataFrame to **Unity DB**:

```python
from unity_sdk.clients import TSClient
from unity_sdk.engine.config import get_secret
from unity_sdk.utils.model_utils import apply_data_types
# get token from secrets manager
TOKEN = get_secret('RND_DB_TOKEN')
DATABASE = "RnD"

tags = ['Site', 'Unit', 'System']

# Apply data types using a Pydantic model to ensure the DataFrame conforms to the expected schema
apply_data_types(df, validation_model)

try:
    with TSClient(token=TOKEN, database=DATABASE) as client:
        client.write(
            data=df,
            # Specify the name of the db table
            data_frame_measurement_name="water_quality_lab_measurements_example",
            data_frame_tag_columns=tags,
            data_frame_timestamp_column='time',
            )

        print("Data inserted successfully.")
except Exception as e:
    print(e)
    raise Exception
```




