# Quickstart Guide

This guide will walk you through the basic usage of Unity SDK, covering the most common operations you'll perform.

## Basic Setup

First, let's set up a basic connection to a time-series database:

```python
from unity_sdk.db.clients import TSClient

# Initialize the client
client = TSClient(
    token="your-influxdb-token",
    database="your-database-name",
    host="https://your-influxdb-host.com",
    namespace="your-organization"
)
```

## Working with TSDataModel

The `TSDataModel` is the core data structure in Unity SDK. Here's how to create and use it:

### Creating a TSDataModel

```python
import pandas as pd
import pyarrow as pa
from unity_sdk.core.models.pipeline_data_block import TSDataModel
from unity_sdk.core.constants import DataModelConstant

# Sample time-series data
data = {
    'time': pd.to_datetime(['2023-01-01 10:00:00', '2023-01-01 10:01:00', '2023-01-01 10:02:00']),
    'location': ['Building A', 'Building B', 'Building A'],
    'sensor_id': ['SN001', 'SN002', 'SN001'],
    'temperature': [22.5, 23.1, 22.7],
    'humidity': [60.1, 62.5, 60.3]
}

df = pd.DataFrame(data)
table = pa.Table.from_pandas(df)

# Configuration for ignoring certain columns
configs = {
    DataModelConstant.IGNORE_TAGS: ['sensor_id'],
    DataModelConstant.IGNORE_FIELDS: []
}

# Build the TSDataModel using the builder pattern
ts_data = (
    TSDataModel.builder()
    .with_measurement("environmental_sensors")
    .with_pyarrow_table(table)
    .with_configs(configs)
    .build()
)

print(f"Measurement: {ts_data.measurement}")
print(f"Tags: {ts_data.tags}")
print(f"Fields: {ts_data.fields}")
```

### Manual Tag and Field Definition

You can also explicitly define tags and fields:

```python
ts_data = (
    TSDataModel.builder()
    .with_measurement("environmental_sensors")
    .with_dataframe(df)
    .with_configs({})
    .with_tags(['location'])
    .with_fields(['temperature', 'humidity'])
    .build()
)
```

## Writing Data

### Writing DataFrames

```python
# Using DataFrame with required parameters
write_kwargs = {
    "data_frame_measurement_name": "sensor_readings",
    "data_frame_tag_columns": ["location"],
    "data_frame_timestamp_column": "time"
}

client.write(df, batch_size=1000, **write_kwargs)
```

### Writing Different Data Types

```python
# List of dictionaries
data_dicts = [
    {"measurement": "temperature", "location": "room1", "value": 23.5, "time": "2023-01-01T10:00:00Z"},
    {"measurement": "temperature", "location": "room2", "value": 24.1, "time": "2023-01-01T10:01:00Z"}
]
client.write(data_dicts)

# List of strings (line protocol format)
line_protocol = [
    "temperature,location=room1 value=23.5 1672574400000000000",
    "temperature,location=room2 value=24.1 1672574460000000000"
]
client.write(line_protocol)
```

## Reading Data

### Basic Queries

```python
# Simple SQL query
query = "SELECT * FROM sensor_readings WHERE time >= '2023-01-01' LIMIT 100"
table = client.read(query, mode='all')
df = table.to_pandas() # pandas DataFrame
print(type(df))
print(df.head())
```

## Data Processing Utilities

### PyArrow Utilities

```python
from unity_sdk.core.utils.data.arrow_utils import extract_tags, extract_fields

# Extract tags and fields from PyArrow table
tags = extract_tags(table, ignore_tags=['sensor_id'])
fields = extract_fields(table)

print(f"Detected tags: {tags}")
print(f"Detected fields: {fields}")
```

### Pandas Utilities

```python
from unity_sdk.core.utils.data.pandas_utils import (
    add_minute_column,
    calculate_time_weighted_average,
    forward_fill_missing_minutes
)

# Add minute-level timestamps
df_with_minutes = add_minute_column(df, 'time', 'time_minute')

# Calculate time-weighted average
twa = calculate_time_weighted_average(df['temperature'], df['time'])
print(f"Time-weighted average: {twa}")

# Forward fill missing data
filled_df = forward_fill_missing_minutes(
    dataframe=df,
    columns=['temperature', 'humidity'],
    group_by_columns=['location'],
    start_time=pd.Timestamp('2023-01-01 10:00:00'),
    end_time=pd.Timestamp('2023-01-01 11:00:00')
)
```

## Context Management

Use the client as a context manager for automatic resource cleanup:

```python
with TSClient(token="your-token", database="your-db") as client:
    # Perform operations
    result = client.read("SELECT * FROM measurements LIMIT 10")
    client.write(data_dicts)
    # Client automatically closes when exiting the block
```

## Error Handling

```python
from unity_sdk.exceptions import (
    TSClientConnectionError,
    TSClientWriteError,
    TSClientReadError,
    TSClientValidationError
)

try:
    client = TSClient(token="invalid-token", database="test-db")
    client.write(invalid_data)
except TSClientConnectionError as e:
    print(f"Connection failed: {e}")
except TSClientValidationError as e:
    print(f"Data validation failed: {e}")
except TSClientWriteError as e:
    print(f"Write operation failed: {e}")
```

## Configuration Best Practices

### Using Environment Variables

```python
import os

# Set environment variables
os.environ['TSDB_HOST'] = 'https://your-host.com'
os.environ['TSDB_NAMESPACE'] = 'your-org'
os.environ['LOG_LEVEL'] = 'INFO'

# Client automatically picks up configuration
client = TSClient(
    token="your-token",
    database="your-database"
    # host and namespace will be resolved automatically
)
```

### Using Configuration Files

Create `unity_sdk_config.toml`:

```toml
[database]
TSDB_HOST = "https://your-influxdb-host.com"
TSDB_NAMESPACE = "your-organization"
```

## Next Steps

- Explore the [Best Practices Guide](../guides/best-practices.md) for advanced usage patterns
- Check the [API Reference](../reference.md) for detailed documentation
- Learn about specific components in the detailed guides