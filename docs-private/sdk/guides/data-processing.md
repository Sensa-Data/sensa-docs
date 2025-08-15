# Data Processing Guide

This guide covers advanced data processing patterns and utilities available in Unity SDK.

## PyArrow Integration

Unity SDK provides sophisticated PyArrow integration for handling metadata-driven data processing.

### Understanding Metadata

PyArrow tables in Unity SDK use IOX metadata format to classify columns:

```python
import pyarrow as pa
from unity_sdk.core.utils.data.arrow_utils import extract_tags, extract_fields

# Example: Table with IOX metadata
schema = pa.schema([
    pa.field('time', pa.timestamp('ns'), metadata={b'iox::column::type': b'timestamp'}),
    pa.field('location', pa.string(), metadata={b'iox::column::type': b'tag'}),
    pa.field('device_id', pa.string(), metadata={b'iox::column::type': b'tag'}),
    pa.field('temperature', pa.float64(), metadata={b'iox::column::type': b'float'}),
    pa.field('humidity', pa.float64(), metadata={b'iox::column::type': b'float'}),
])

# Create table with data
data = [
    ['2023-01-01T10:00:00', '2023-01-01T10:01:00'],
    ['room_1', 'room_2'],
    ['sensor_001', 'sensor_002'],
    [23.5, 24.1],
    [60.2, 58.7]
]
table = pa.Table.from_arrays(data, schema=schema)

# Extract metadata-based classifications
tags = extract_tags(table)  # ['location', 'device_id']
fields = extract_fields(table)  # ['temperature', 'humidity']
```

### Field Type Grouping

Group fields by their data types for specialized processing:

```python
from unity_sdk.core.utils.data.arrow_utils import extract_fields_grouping

# Group fields by type
field_groups = extract_fields_grouping(table)
print(field_groups)
# {
#     'float': ['temperature', 'humidity'],
#     'integer': [],
#     'string': []
# }

# Process specific field types
float_fields = field_groups['float']
for field in float_fields:
    # Apply float-specific processing
    pass
```

### Ignoring Columns

Control which columns to include or exclude:

```python
# Ignore specific tags and fields
tags = extract_tags(table, ignore_tags=['device_id'])
fields = extract_fields(table, ignore_fields=['debug_field'])

# Use in TSDataModel
from unity_sdk.core.constants import DataModelConstant

configs = {
    DataModelConstant.IGNORE_TAGS: ['device_id', 'internal_id'],
    DataModelConstant.IGNORE_FIELDS: ['debug_info', 'raw_signal']
}
```

## Time-Series Operations

### Time-Weighted Averages

Calculate time-weighted averages for irregular time-series data:

```python
import pandas as pd
from unity_sdk.core.utils.data.pandas_utils import calculate_time_weighted_average

# Sample irregular time-series data
data = pd.DataFrame({
    'time': pd.to_datetime([
        '2023-01-01 10:00:00',
        '2023-01-01 10:00:15',  # 15 seconds later
        '2023-01-01 10:00:45',  # 30 seconds later
        '2023-01-01 10:00:50'   # 5 seconds later
    ]),
    'value': [20.0, 25.0, 22.0, 21.0]
})

# Calculate time-weighted average
twa = calculate_time_weighted_average(data['value'], data['time'])
print(f"Time-weighted average: {twa:.2f}")

# Compare with simple average
simple_avg = data['value'].mean()
print(f"Simple average: {simple_avg:.2f}")
```

### Forward Filling Missing Data

Fill gaps in time-series data using forward-fill strategy:

```python
from unity_sdk.core.utils.data.pandas_utils import forward_fill_missing_minutes
from datetime import datetime

# Sample data with gaps
df = pd.DataFrame({
    'time': pd.to_datetime([
        '2023-01-01 10:00:00',
        '2023-01-01 10:02:00',  # Missing 10:01:00
        '2023-01-01 10:05:00'   # Missing 10:03:00, 10:04:00
    ]),
    'location': ['room_1', 'room_1', 'room_1'],
    'temperature': [23.5, 24.1, 23.8]
})

# Forward fill missing minutes
filled_df = forward_fill_missing_minutes(
    dataframe=df,
    columns=['temperature'],
    group_by_columns=['location'],
    start_time=datetime(2023, 1, 1, 10, 0),
    end_time=datetime(2023, 1, 1, 10, 6)
)

print(f"Original records: {len(df)}")
print(f"After forward fill: {len(filled_df)}")
```

### Multi-Group Forward Filling

Handle multiple groups with different field sets:

```python
# Data with multiple locations and varying sensors
df = pd.DataFrame({
    'time': pd.to_datetime(['2023-01-01 10:00:00'] * 3),
    'location': ['room_1', 'room_2', 'room_3'],
    'sensor_type': ['temp_humid', 'temp_only', 'temp_humid'],
    'temperature': [23.5, 24.1, 22.8],
    'humidity': [60.2, None, 58.9]  # room_2 has no humidity sensor
})

# Map group combinations to their specific fields
group_mapping = {
    ('room_1', 'temp_humid'): ['temperature', 'humidity'],
    ('room_2', 'temp_only'): ['temperature'],
    ('room_3', 'temp_humid'): ['temperature', 'humidity']
}

filled_df = forward_fill_missing_minutes(
    dataframe=df,
    columns=['temperature', 'humidity'],
    group_by_columns=['location', 'sensor_type'],
    group_column_tuple_mapping=group_mapping,
    start_time=datetime(2023, 1, 1, 10, 0),
    end_time=datetime(2023, 1, 1, 11, 0)
)
```

## Data Combination Analysis

### Finding Missing Combinations

Identify missing combinations of categorical variables:

```python
from unity_sdk.core.utils.data.pandas_utils import (
    get_existing_combinations_in_df,
    get_missing_combinations_in_df,
    create_dummy_rows_for_combinations
)

# Current data
df = pd.DataFrame({
    'location': ['room_1', 'room_1', 'room_2'],
    'sensor_type': ['temperature', 'humidity', 'temperature'],
    'value': [23.5, 60.2, 24.1]
})

# Expected combinations
expected_combinations = [
    {'location': 'room_1', 'sensor_type': 'temperature'},
    {'location': 'room_1', 'sensor_type': 'humidity'},
    {'location': 'room_2', 'sensor_type': 'temperature'},
    {'location': 'room_2', 'sensor_type': 'humidity'},  # Missing!
]

# Find missing combinations
missing = get_missing_combinations_in_df(
    dataframe=df,
    columns=['location', 'sensor_type'],
    column_value_combinations=expected_combinations
)

print(f"Missing combinations: {missing}")
# [{'location': 'room_2', 'sensor_type': 'humidity'}]
```

### Creating Placeholder Data

Generate dummy rows for missing combinations:

```python
# Create dummy rows for missing combinations
dummy_rows = create_dummy_rows_for_combinations(
    field_name='value',
    combinations=missing,
    columns=['location', 'sensor_type'],
    time_column_name='timestamp',
    time_column_value=datetime.now()
)

# Combine with original data
complete_df = pd.concat([df, dummy_rows], ignore_index=True)
```

## Advanced DataFrame Operations

### Minute-Level Aggregation

Add minute-level timestamps for aggregation:

```python
from unity_sdk.core.utils.data.pandas_utils import add_minute_column

# High-frequency data
df = pd.DataFrame({
    'time': pd.date_range('2023-01-01 10:00:00', periods=100, freq='6S'),
    'value': range(100)
})

# Add minute column for grouping
df_with_minutes = add_minute_column(df, 'time', 'time_minute')

# Aggregate by minute
minute_aggregates = df_with_minutes.groupby('time_minute').agg({
    'value': ['mean', 'min', 'max', 'count']
}).round(2)

print(minute_aggregates.head())
```

## Data Type Conversion

### PyArrow to Pandas Conversion

Convert PyArrow tables to properly typed DataFrames:

```python
from unity_sdk.core.utils.data.arrow_utils import extract_dataframe_type_mapping_from_schema
from unity_sdk.core.constants import ArrowMetadataConstant

# Convert with proper data types
type_mapping = extract_dataframe_type_mapping_from_schema(
    table,
    ArrowMetadataConstant.COLUMN_TYPE_DATAFRAME_MAPPING
)

# Convert to pandas with explicit types
df = table.to_pandas()
df = df.astype(type_mapping)

print(df.dtypes)
```
