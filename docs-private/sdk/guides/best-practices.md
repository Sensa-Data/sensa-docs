# Best Practices

This guide covers recommended patterns and practices for using Unity SDK effectively in production environments.

## Client Management

### Context Manager

Always use context managers for automatic resource cleanup:

```python
# ✅ Good: Automatic cleanup
with TSClient(token=token, database=db_name) as client:
    result = client.read(query)
    client.write(data)

# ❌ Avoid: Manual cleanup required
client = TSClient(token=token, database=db_name)
try:
    result = client.read(query)
finally:
    client.close()  # Easy to forget
```

### Configuration Management

Use environment variables or configuration files instead of hardcoding values:

```python
# ✅ Good: Environment-based configuration
import os

client = TSClient(
    token=os.getenv('INFLUX_TOKEN'),
    database=os.getenv('INFLUX_DATABASE'),
    # host and namespace resolved automatically
)

# ❌ Avoid: Hardcoded values
client = TSClient(
    token="xoxb-hardcoded-token",
    database="production-db",
    host="https://influx.company.com"
)
```

## Data Processing

### Batch Size Optimization

Choose appropriate batch sizes based on your data characteristics:

```python
# For large datasets with simple records
client.write(complex_dataframe, batch_size=1000)

# For real-time processing
client.write(streaming_data, batch_size=100)
```

### Data Validation

Always validate data before writing:

```python
def validate_and_write(df: pd.DataFrame, client: TSClient):
    """Validate DataFrame before writing."""
    
    # Check for required columns
    required_cols = ['time', 'measurement', 'value']
    missing_cols = [col for col in required_cols if col not in df.columns]
    if missing_cols:
        raise ValueError(f"Missing required columns: {missing_cols}")
    
    # Check for null values in critical columns
    if df['time'].isnull().any():
        raise ValueError("Null values found in time column")
    
    # Validate data types
    if not pd.api.types.is_datetime64_any_dtype(df['time']):
        df['time'] = pd.to_datetime(df['time'])
    
    # Write validated data
    client.write(df, **write_params)
```

## TSDataModel Usage

### Builder Pattern Best Practices

Use method chaining for clean, readable code:

```python
# ✅ Good: Clear builder chain
ts_model = (
    TSDataModel.builder()
    .with_measurement("sensor_data")
    .with_pyarrow_table(arrow_table)
    .with_configs({
        DataModelConstant.IGNORE_TAGS: ['internal_id'],
        DataModelConstant.IGNORE_FIELDS: ['debug_info']
    })
    .build()
)

# ❌ Avoid: Verbose step-by-step
builder = TSDataModel.builder()
builder.with_measurement("sensor_data")
builder.with_pyarrow_table(arrow_table)
builder.with_configs(configs)
ts_model = builder.build()
```

### Configuration Strategy

Define reusable configurations:

```python
# Define common configurations
SENSOR_CONFIG = {
    DataModelConstant.IGNORE_TAGS: ['device_serial', 'firmware_version'],
    DataModelConstant.IGNORE_FIELDS: ['battery_level', 'signal_strength']
}

WEATHER_CONFIG = {
    DataModelConstant.IGNORE_TAGS: ['station_id'],
    DataModelConstant.IGNORE_FIELDS: ['quality_flag']
}

# Reuse configurations
sensor_model = (
    TSDataModel.builder()
    .with_measurement("sensors")
    .with_dataframe(sensor_df)
    .with_configs(SENSOR_CONFIG)
    .build()
)
```

## Error Handling

### Comprehensive Exception Handling

Handle specific exceptions for better error recovery:

```python
from unity_sdk.exceptions import *

def robust_data_write(data, client):
    """Write data with comprehensive error handling."""
    try:
        client.write(data, batch_size=5000)
        return True
        
    except TSClientValidationError as e:
        logger.error(f"Data validation failed: {e}")
        # Handle validation errors (fix data, skip invalid records, etc.)
        return False
        
    except TSClientConnectionError as e:
        logger.error(f"Connection failed: {e}")
        # Handle connection issues (retry, fallback, etc.)
        return False
        
    except TSClientWriteError as e:
        logger.error(f"Write failed: {e}")
        # Handle write errors (retry with smaller batch, etc.)
        return False
        
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        # Handle unexpected errors
        raise
```

## Performance Optimization

### Query Optimization

Write efficient queries for better performance:

```python
# ✅ Good: Specific time ranges and limits
query = """
    SELECT location, AVG(temperature) as avg_temp
    FROM sensor_data
    WHERE time >= '2023-01-01T00:00:00Z' 
      AND time < '2023-01-02T00:00:00Z'
      AND location IN ('building_a', 'building_b')
    GROUP BY location
    LIMIT 1000
"""

# ❌ Avoid: Open-ended queries
query = "SELECT * FROM sensor_data"  # Can return millions of rows
```

### Pandas Operations

Use efficient pandas operations:

```python
# ✅ Good: Vectorized operations
df['temp_celsius'] = (df['temp_fahrenheit'] - 32) * 5/9

# ❌ Avoid: Iterative operations
df['temp_celsius'] = df['temp_fahrenheit'].apply(lambda x: (x - 32) * 5/9)

# ✅ Good: Bulk operations
df_resampled = df.set_index('time').resample('1H').mean()

# ❌ Avoid: Manual grouping
hourly_data = df.groupby(df['time'].dt.hour).mean()
```

## Logging and Monitoring

### Structured Logging

Use structured logging for better observability:

```python
import logging
from unity_sdk.custom_logger import get_logger

logger = get_logger(__name__)

def process_sensor_data(data_source: str, record_count: int):
    """Process sensor data with structured logging."""
    logger.info(
        "Starting data processing",
        extra={
            "data_source": data_source,
            "record_count": record_count,
            "operation": "data_processing"
        }
    )
    
    try:
        # Process data...
        logger.info(
            "Data processing completed successfully",
            extra={
                "data_source": data_source,
                "records_processed": record_count,
                "operation": "data_processing"
            }
        )
    except Exception as e:
        logger.error(
            "Data processing failed",
            extra={
                "data_source": data_source,
                "error": str(e),
                "operation": "data_processing"
            }
        )
        raise
```

## Testing

### Unit Testing

Write testable code with dependency injection:

```python
import pytest
from unittest.mock import Mock, patch

class DataProcessor:
    def __init__(self, client: TSClient):
        self.client = client
    
    def process_and_write(self, data: pd.DataFrame):
        """Process and write data."""
        processed = self._transform_data(data)
        self.client.write(processed)
        return len(processed)
    
    def _transform_data(self, data: pd.DataFrame) -> pd.DataFrame:
        """Transform data (pure function - easy to test)."""
        return data.copy()

# Test
def test_data_processor():
    mock_client = Mock(spec=TSClient)
    processor = DataProcessor(mock_client)
    
    test_data = pd.DataFrame({'value': [1, 2, 3]})
    result = processor.process_and_write(test_data)
    
    assert result == 3
    mock_client.write.assert_called_once()
```

### Integration Testing

Test with real database connections in controlled environments:

```python
@pytest.fixture
def test_client():
    """Fixture for test database client."""
    return TSClient(
        token=os.getenv('TEST_INFLUX_TOKEN'),
        database='test_database',
        host=os.getenv('TEST_INFLUX_HOST')
    )

def test_write_and_read_cycle(test_client):
    """Test complete write/read cycle."""
    # Write test data
    test_data = pd.DataFrame({
        'time': [pd.Timestamp.now()],
        'location': ['test'],
        'value': [42.0]
    })
    
    test_client.write(test_data, measurement="test_measurement")
    
    # Read back data
    query = "SELECT * FROM test_measurement WHERE location = 'test'"
    result = test_client.read(query, mode='pandas')
    
    assert len(result) >= 1
    assert result.iloc[0]['value'] == 42.0
```

## Security

### Credential Management

Never hardcode credentials:

```python
# ✅ Good: Environment variables
import os
from pathlib import Path

def get_client():
    """Get client with secure credential handling."""
    token = os.getenv('INFLUX_TOKEN')
    if not token:
        raise ValueError("INFLUX_TOKEN environment variable not set")
    
    return TSClient(
        token=token,
        database=os.getenv('INFLUX_DATABASE', 'default'),
        host=os.getenv('INFLUX_HOST')
    )

# ❌ Avoid: Hardcoded credentials
def get_client():
    """Insecure client initialization with hardcoded credentials."""
    # This exposes sensitive information in source code
    token = 'my-secret-token-12345'
    host = 'https://insecure-host.example.com'
    
    return TSClient(
        token=token,
        database='hardcoded_database',
        host=host
    )
```
