# Installation

## Prerequisites

- Python 3.10 or higher
- pip package manager

## Installation Methods

### Standard Installation

Install the Unity SDK using pip:

```bash
pip install "unity_python_sdk @ <SDK_WHEEL_URL>"
```

> **Note**: Please contact Sensa for the *SDK_WHEEL_URL*.

### Development Installation

For development or testing with the latest features:

```bash
# Clone the repository
git clone <repository-url>
cd unity_sdk

# Install in development mode
pip install -e .
```

### With Development Dependencies

To install with testing and development tools:

```bash
pip install "unity_python_sdk[dev] @ <SDK_WHEEL_URL>"
```

## Dependencies

The Unity SDK automatically installs the following core dependencies:

- **pandas (2.2.3)**: Data manipulation and analysis
- **influxdb3-python (0.12.0)**: InfluxDB client library
- **pydantic (2.10.3)**: Data validation and serialization
- **pdoc (15.0.3)**: API documentation generation

## Optional Dependencies

Depending on your use case, you may need additional packages:

```bash
# For PyArrow support (recommended for large datasets)
pip install pyarrow

# For TOML configuration file support
pip install tomli  # Python 3.10 and earlier
# tomllib is built-in for Python 3.11+
```

## Verification

Verify your installation by importing the SDK:

```python
import unity_sdk
from unity_sdk.db.clients import TSClient
from unity_sdk.core.models.pipeline_data_block import TSDataModel

print("Unity SDK installed successfully!")
```

## Configuration

### Environment Variables

Set up basic configuration using environment variables:

```bash
export TSDB_HOST="https://your-influxdb-host.com"
export TSDB_NAMESPACE="your-organization"
export LOG_LEVEL="INFO"
```

### Configuration File

Alternatively, create a `unity_sdk_config.toml` file in your project root:

```toml
[database]
TSDB_HOST = "https://your-influxdb-host.com"
TSDB_NAMESPACE = "your-organization"
```

## Troubleshooting

### Common Issues

**ImportError: No module named 'unity_sdk'**
- Ensure the package is installed: `pip list | grep unity`
- Check your Python environment is correct

**Connection Issues**
- Verify your database configuration
- Check network connectivity to your InfluxDB instance
- Ensure authentication credentials are correct

**Version Conflicts**
- Use a virtual environment to avoid dependency conflicts:
```bash
python -m venv unity_env
source unity_env/bin/activate  # On Windows: unity_env\Scripts\activate
pip install unity_python_sdk
```

## Next Steps

Now that you have Unity SDK installed, proceed to the [Quickstart Guide](03-quickstart.md) to learn basic usage patterns.