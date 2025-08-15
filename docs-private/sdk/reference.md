# API Reference

Complete reference documentation for Unity SDK components.

## Database Clients

### TSClient

The primary client for interacting with time-series databases.

```python
from unity_sdk.db.clients.ts import TSClient
```

#### Constructor

```python
TSClient(
    token: str,
    database: str,
    host: str = None,
    namespace: str = None,
    timeout: int = 10_000
)
```

**Parameters:**
- `token` (str): Authentication token for the database
- `database` (str): Target database name
- `host` (str, optional): Database host URL. Auto-resolved if not provided
- `namespace` (str, optional): Organization/namespace. Auto-resolved if not provided  
- `timeout` (int): Connection timeout in milliseconds. Default: 10,000

**Raises:**
- `TSClientConnectionError`: If client initialization fails

#### Methods

##### write()

Write data to the database in batches.

```python
write(
    data: Any,
    database: str | None = None,
    batch_size: int = None,
    **kwargs
) -> None
```

**Parameters:**
- `data`: Data to write (DataFrame, list of dicts, list of strings, etc.)
- `database` (str, optional): Override default database
- `batch_size` (int, optional): Records per batch. Default: 5000
- `**kwargs`: Additional parameters based on data type

**DataFrame-specific kwargs:**
- `data_frame_measurement_name` (str): Required measurement name
- `data_frame_tag_columns` (list[str]): Required tag column names
- `data_frame_timestamp_column` (str): Required timestamp column name
- `timezone` (str, optional): Timezone for timestamp localization
- `default_timestamp` (pd.Timestamp, optional): Default timestamp value

**Raises:**
- `TSClientValidationError`: If data validation fails
- `TSClientWriteError`: If write operation fails

**Example:**
```python
# Write DataFrame
df_kwargs = {
    "data_frame_measurement_name": "sensors",
    "data_frame_tag_columns": ["location", "device"],
    "data_frame_timestamp_column": "timestamp"
}
client.write(dataframe, **df_kwargs)

# Write list of dictionaries
data = [{"measurement": "temp", "value": 23.5, "time": "2023-01-01T10:00:00Z"}]
client.write(data)
```

##### read()

Execute SQL queries and return results.

```python
read(query: str, mode: str = 'all') -> Any
```

**Parameters:**
- `query` (str): SQL query string
- `mode` (str): Result format. Options: 'all', 'pandas', 'polars', 'chunk', 'reader', 'schema'

**Returns:**
- Result in specified format (dict, DataFrame, etc.)

**Raises:**
- `TSClientReadError`: If query execution fails

**Example:**
```python
# Return as pandas DataFrame
df = client.read("SELECT * FROM sensors LIMIT 100", mode='pandas')

# Return as dictionary
result = client.read("SELECT COUNT(*) FROM sensors", mode='all')
```

##### close()

Close the database connection.

```python
close() -> None
```

**Raises:**
- `TSClientConnectionError`: If closing fails

#### Context Manager Support

TSClient supports context manager protocol for automatic resource cleanup:

```python
with TSClient(token=token, database=db) as client:
    client.write(data)
    result = client.read(query)
# Client automatically closed
```

---

## Data Models

### TSDataModel

Core data structure representing time-series data with metadata.

```python
from unity_sdk.core.models.pipeline_data_block import TSDataModel
```

#### Properties

- `measurement` (str): Measurement name
- `configs` (dict): Configuration dictionary
- `dataframe` (pd.DataFrame): Time-series data
- `tags` (list[str]): Tag column names
- `fields` (list[str]): Field column names

#### Methods

##### __init__()

```python
TSDataModel(
    measurement: str,
    configs: dict[str, Any],
    dataframe: pd.DataFrame,
    tags: list[str],
    fields: list[str]
)
```

##### to_dict()

Convert model to dictionary representation.

```python
to_dict() -> dict
```

##### from_dict()

Create model from dictionary (class method).

```python
@classmethod
from_dict(cls, data_dict: dict) -> TSDataModel
```

##### copy()

Create deep copy of the model.

```python
copy() -> TSDataModel
```

##### builder()

Create a new builder instance (class method).

```python
@classmethod
builder(
    cls,
    measurement: str = None,
    configs: dict = None
) -> TSDataModelBuilder
```

**Example:**
```python
model = TSDataModel.builder().with_measurement("sensors").build()
```

### TSDataModelBuilder

Builder class for constructing TSDataModel instances with fluent API.

```python
from unity_sdk.core.models.pipeline_data_block import TSDataModelBuilder
```

#### Constructor

```python
TSDataModelBuilder(
    measurement: str = None,
    configs: dict[str, Any] = None
)
```

#### Methods

##### with_measurement()

Set the measurement name.

```python
with_measurement(measurement: str) -> TSDataModelBuilder
```

**Raises:**
- `ValueError`: If measurement is invalid (None or empty)

##### with_configs()

Set configuration dictionary.

```python
with_configs(configs: dict[str, Any]) -> TSDataModelBuilder
```

**Raises:**
- `ValueError`: If configs is not a dictionary

##### with_pyarrow_table()

Set data source as PyArrow table.

```python
with_pyarrow_table(table: pa.Table) -> TSDataModelBuilder
```

**Raises:**
- `ValueError`: If table is not a valid PyArrow table

##### with_dataframe()

Set data source as Pandas DataFrame.

```python
with_dataframe(dataframe: pd.DataFrame) -> TSDataModelBuilder
```

**Raises:**
- `ValueError`: If dataframe is not a Pandas DataFrame

##### with_tags()

Explicitly set tag column names.

```python
with_tags(tags: list[str]) -> TSDataModelBuilder
```

**Raises:**
- `ValueError`: If tags is not a non-empty list

##### with_fields()

Explicitly set field column names.

```python
with_fields(fields: list[str]) -> TSDataModelBuilder
```

**Raises:**
- `ValueError`: If fields is not a non-empty list

##### build()

Build and return TSDataModel instance.

```python
build() -> TSDataModel
```

**Raises:**
- `ValueError`: If builder state is invalid

**Example:**
```python
model = (
    TSDataModelBuilder()
    .with_measurement("environmental_data")
    .with_dataframe(df)
    .with_configs({DataModelConstant.IGNORE_TAGS: ['device_id']})
    .with_tags(['location'])
    .with_fields(['temperature', 'humidity'])
    .build()
)
```

---

## Utility Functions

### PyArrow Utilities

```python
from unity_sdk.core.utils.data.arrow_utils import *
```

#### extract_tags()

Extract tag column names from PyArrow table metadata.

```python
extract_tags(
    table: pa.Table,
    ignore_tags: list[str] = None
) -> list[str]
```

**Parameters:**
- `table`: PyArrow table with metadata
- `ignore_tags`: Tag columns to exclude

**Returns:**
- List of tag column names

**Raises:**
- `ValueError`: If table schema is None
- `KeyError`: If column lacks required metadata

#### extract_fields()

Extract field column names from PyArrow table metadata.

```python
extract_fields(
    table: pa.Table,
    ignore_fields: list[str] = None
) -> list[str]
```

**Parameters:**
- `table`: PyArrow table with metadata
- `ignore_fields`: Field columns to exclude

**Returns:**
- List of field column names

#### extract_fields_grouping()

Group field columns by data types.

```python
extract_fields_grouping(
    table: pa.Table,
    groups: list[str] = None
) -> dict[str, list[str]]
```

**Parameters:**
- `table`: PyArrow table with metadata
- `groups`: Data type groups to extract

**Returns:**
- Dictionary mapping data types to column lists

#### get_column_field_type()

Extract field type from PyArrow Field metadata.

```python
get_column_field_type(column: pa.Field) -> str | None
```

### Pandas Utilities

```python
from unity_sdk.core.utils.data.pandas_utils import *
```

#### add_minute_column()

Add minute-level timestamp column to DataFrame.

```python
add_minute_column(
    dataframe: pd.DataFrame,
    time_column_name: str = DataModelConstant.TIME_COLUMN,
    minute_column_name: str = DataModelConstant.TIME_MINUTE_COLUMN,
    new_copy: bool = False
) -> pd.DataFrame
```

**Parameters:**
- `dataframe`: Input DataFrame
- `time_column_name`: Source timestamp column name
- `minute_column_name`: Target minute column name
- `new_copy`: Whether to create deep copy

**Returns:**
- DataFrame with minute column added

#### calculate_time_weighted_average()

Calculate time-weighted average of values.

```python
calculate_time_weighted_average(
    values: pd.Series,
    timestamps: pd.Series
) -> float
```

**Parameters:**
- `values`: Numerical values series
- `timestamps`: Corresponding timestamps series

**Returns:**
- Time-weighted average value

#### forward_fill_missing_minutes()

Forward-fill missing minute-level data in time-series.

```python
forward_fill_missing_minutes(
    dataframe: pd.DataFrame,
    columns: list[str],
    group_by_columns: list[str],
    start_time: datetime,
    end_time: datetime,
    group_column_tuple_mapping: dict[tuple, str] = None,
    time_column_name: str = DataModelConstant.TIME_COLUMN
) -> pd.DataFrame
```

**Parameters:**
- `dataframe`: Input time-series DataFrame
- `columns`: Columns to include in output
- `group_by_columns`: Columns to group data by
- `start_time`: Start of time range (inclusive)
- `end_time`: End of time range (exclusive)
- `group_column_tuple_mapping`: Custom field mapping per group
- `time_column_name`: Timestamp column name

**Returns:**
- DataFrame with missing minutes forward-filled

#### get_existing_combinations_in_df()

Extract unique combinations of column values.

```python
get_existing_combinations_in_df(
    dataframe: pd.DataFrame,
    columns: list[str]
) -> set[tuple[Any, ...]]
```

#### get_missing_combinations_in_df()

Find combinations not present in DataFrame.

```python
get_missing_combinations_in_df(
    dataframe: pd.DataFrame,
    columns: list[str],
    column_value_combinations: list[dict[str, str]]
) -> list[dict[str, str]]
```

#### create_dummy_rows_for_combinations()

Create dummy rows for specified combinations.

```python
create_dummy_rows_for_combinations(
    field_name: str,
    combinations: list[dict[str, str]],
    columns: list[str],
    time_column_name: str = DataModelConstant.TIME_COLUMN,
    time_column_value: datetime = None
) -> pd.DataFrame
```

---

## Constants

### DataModelConstant

```python
from unity_sdk.core.constants import DataModelConstant
```

Core constants for data model configuration:

- `TIME_COLUMN`: Default time column name ("time")
- `TIME_MINUTE_COLUMN`: Default minute column name ("time_minute")
- `INTEGER_FIELD`: Integer field type identifier ("integer")
- `FLOAT_FIELD`: Float field type identifier ("float")
- `STRING_FIELD`: String field type identifier ("string")
- `IGNORE_TAGS`: Configuration key for ignored tags ("ignore_tags")
- `IGNORE_FIELDS`: Configuration key for ignored fields ("ignore_fields")

### ArrowMetadataConstant

```python
from unity_sdk.core.constants import ArrowMetadataConstant
```

Constants for PyArrow metadata handling:

- `IOX_COLUMN_TYPE_KEY`: Metadata key for column type (b"iox::column::type")
- `IOX_TAG_TYPE_KEY`: Tag type identifier (b"tag")
- `METADATA_TO_GROUP_MAP`: Mapping from metadata suffixes to group names
- `COLUMN_TYPE_DATAFRAME_MAPPING`: Mapping from column types to pandas dtypes

### TSClientVariable

```python
from unity_sdk.db.clients.ts.constants import TSClientVariable
```

Time-series client configuration:

- `HOST`: Environment variable for database host ("TSDB_HOST")
- `NAMESPACE`: Environment variable for namespace ("TSDB_NAMESPACE")
- `BATCH_SIZE`: Default batch size for write operations (5000)

---

## Exceptions

### Exception Hierarchy

```python
from unity_sdk.exceptions import *
```

All SDK exceptions inherit from `UnitySDKException`:

```
UnitySDKException
├── TSClientConnectionError
├── TSClientWriteError
├── TSClientReadError
├── TSClientValidationError
├── TSClientFunctionNotImplementedError
└── EngineRuntimeImportError
```

#### UnitySDKException

Base exception class for all SDK errors.

```python
class UnitySDKException(Exception):
    default_message: str = "An error occurred in the Unity SDK."
    
    def __init__(self, message: str | None = None) -> None:
        super().__init__(message or self.default_message)
```

#### TSClientConnectionError

Raised for database connection issues.

**Default message:** "Failed to connect to the database."

#### TSClientWriteError

Raised for data write operation failures.

**Default message:** "Error occurred while writing data to the database."

#### TSClientReadError

Raised for data query operation failures.

**Default message:** "Error occurred while querying data from the database."

#### TSClientValidationError

Raised for data validation failures.

**Default message:** "Data validation failed."

#### TSClientFunctionNotImplementedError

Raised when functionality is not available.

**Default message:** "This function is not available for this database."

#### EngineRuntimeImportError

Raised when engine modules are not available.

**Default message:** "Cannot import outside Engine runtime. Please run this code inside the Unity Engine environment."

---

## Data Processors

### DataProcessor (Abstract Base)

```python
from unity_sdk.db.clients.ts.processors import DataProcessor
```

Abstract base class for data processors.

#### Methods

```python
@abstractmethod
def process(self, data: Any, **kwargs) -> Any:
    """Process the data according to its type"""

@abstractmethod
def validate_kwargs(self, **kwargs) -> None:
    """Validate required kwargs for this data type"""

@abstractmethod
def create_batches(self, data: Any, batch_size: int) -> Iterator[Any]:
    """Create batches from the data for writing"""
```

### DataFrameProcessor

Processes pandas DataFrames with timestamp handling and timezone conversion.

#### Special kwargs for DataFrame processing:

- `data_frame_measurement_name` (str): **Required** - Measurement name
- `data_frame_tag_columns` (list[str]): **Required** - Tag column names  
- `data_frame_timestamp_column` (str): **Required** - Timestamp column name
- `timezone` (str, optional): Timezone for naive timestamp localization
- `default_timestamp` (pd.Timestamp, optional): Default timestamp if column missing

### ProcessorFactory

Factory for getting appropriate data processor based on data type.

```python
from unity_sdk.db.clients.ts.processors import ProcessorFactory

factory = ProcessorFactory()
processor = factory.get_processor(data)
```

**Supported data types:**
- `pd.DataFrame` → `DataFrameProcessor`
- `list[dict]` → `ListDictProcessor`
- `list[str]` → `ListStringProcessor`
- `list[Point]` → `ListPointProcessor`
- `str` → `StringProcessor`
- `Point` → `PointProcessor`

---

## Logging

### Custom Logger

```python
from unity_sdk.custom_logger import get_logger

logger = get_logger(__name__)
```

#### get_logger()

Create logger with environment-based configuration.

```python
get_logger(name: str) -> logging.Logger
```

**Parameters:**
- `name`: Logger name (typically `__name__`)

**Environment Variables:**
- `LOG_LEVEL`: Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL). Default: WARNING

**Returns:**
- Configured logger instance with StreamHandler and formatted output

**Example:**
```python
import os
from unity_sdk.custom_logger import get_logger

# Set log level
os.environ['LOG_LEVEL'] = 'INFO'

logger = get_logger(__name__)
logger.info("This is an info message")
logger.warning("This is a warning")
```

---

## Configuration Utilities

### Configuration Resolution

```python
from unity_sdk.db.clients.ts.utils import resolve_db_config_value
```

#### resolve_db_config_value()

Resolve configuration values from environment variables or TOML files.

```python
resolve_db_config_value(
    env_var_name: str,
    display_name: str,
    config_filename: str = "unity_sdk_config.toml",
    project_root: Path = None
) -> str
```

**Parameters:**
- `env_var_name`: Environment variable name to check
- `display_name`: Human-readable name for error messages
- `config_filename`: TOML configuration file name
- `project_root`: Directory to search for config file

**Resolution Priority:**
1. Environment variable
2. TOML configuration file under `[database]` section

**Returns:**
- Resolved configuration value

**Raises:**
- `TSClientConnectionError`: If value cannot be resolved

**Example TOML configuration:**
```toml
[database]
TSDB_HOST = "https://influx.example.com"
TSDB_NAMESPACE = "my-organization"
```

---

## Engine Integration

### Pipeline Decorators

```python
from unity_sdk.engine.decorators import *
```

Static decorator definitions for pipeline development. These decorators are no-ops in the SDK but are dynamically defined at runtime in the engine environment.

**Available decorators:**
- `@data_loader`
- `@transformer`  
- `@data_exporter`
- `@test`
- `@callback`
- `@condition`
- `@custom`
- `@sensor`
- `@on_success`
- `@on_failure`

**Example:**
```python
from unity_sdk.engine.decorators import data_loader, transformer

@data_loader
def load_sensor_data():
    """Load sensor data from source."""
    pass

@transformer
def process_sensor_data(data):
    """Transform sensor data."""
    pass
```

### Secret Management

```python
from unity_sdk.engine.config import get_secret
```

#### get_secret()

Retrieve secrets from the engine environment.

```python
get_secret(key: str) -> str
```

**Parameters:**
- `key`: Secret key name

**Returns:**
- Secret value

**Raises:**
- `EngineRuntimeImportError`: If not running in engine environment

**Note:** This function requires the Mage AI engine runtime and will fail outside that environment.

---

## File I/O Utilities

### JSON Reader

```python
from unity_sdk.core.utils.io.readers import read_json
```

#### read_json()

Read and parse JSON files.

```python
read_json(file_loc: str) -> dict
```

**Parameters:**
- `file_loc`: Path to JSON file

**Returns:**
- Parsed JSON data as dictionary

**Example:**
```python
data = read_json('/path/to/config.json')
print(data['setting'])
```

---

## Type Hints and Annotations

Unity SDK uses comprehensive type hints throughout the codebase. Key type imports:

```python
from typing import Any, Optional, Dict, List, Iterator, Union
import pandas as pd
import pyarrow as pa
from datetime import datetime
from influxdb_client_3 import Point
```

Common type patterns:
- `pd.DataFrame` for pandas DataFrames
- `pa.Table` for PyArrow tables  
- `list[dict]` for list of dictionaries
- `list[str]` for list of strings
- `Optional[T]` for nullable types
- `Union[T, U]` for multiple possible types

---

## Version Information

**Current Version:** 1.0.0

**Python Requirements:** >= 3.10

**Key Dependencies:**
- pandas == 2.2.3
- influxdb3-python == 0.12.0
- pydantic == 2.10.3

For the complete dependency list, see the project's `pyproject.toml` file.
