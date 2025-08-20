# Unity SDK Overview

The Unity SDK is a comprehensive Python library designed for time-series data processing and database operations. It provides a unified interface for working with time-series databases, data transformation utilities, and pipeline building components.

## Key Features

### 🗄️ Database Clients
- **Time-Series Database Support**: Native integration with time-series databases through the `TSClient`.
- **Flexible Data Formats**: Support for Pandas DataFrames, PyArrow tables, dictionaries, and InfluxDB Points.
- **Batch Processing**: Efficient batch writing with configurable batch sizes.

### 📊 Data Processing
- **PyArrow Integration**: Advanced metadata extraction and column classification.
- **Pandas Utilities**: Time-weighted averages, forward-filling, and data manipulation.
- **Schema Validation**: Automatic tag and field detection based on metadata.
- **Data Type Conversion**: Seamless conversion between different data formats.

### 🏗️ Pipeline Components
- **TSDataModel**: Core data structure for time-series data with metadata.
- **Builder Pattern**: Fluent API for constructing data models.
- **Processor Factory**: Automatic data type detection and processing.

### 🛠️ Developer Experience
- **Type Safety**: Comprehensive type hints throughout the codebase.
- **Error Handling**: Custom exception hierarchy with meaningful error messages.
- **Logging**: Configurable logging with environment-based log levels.
- **Configuration**: Flexible configuration via environment variables or TOML files.

## Architecture Overview

```
Unity SDK
├── Core Components
│   ├── TSDataModel & Builder
│   ├── Constants & Configuration
│   └── Utility Functions
├── Database Clients
│   ├── Base Client Interface
│   └── Time-Series Client
├── Data Processing
│   ├── PyArrow Utilities
│   ├── Pandas Operations
│   └── Data Type Processors
└── Engine Integration
    ├── Pipeline Decorators
    └── Configuration Management
```

## Use Cases

- **ETL Pipelines**: Build robust data extraction, transformation, and loading workflows in Unity Engine.
- **Time-Series Analytics**: Process and analyze time-series data with built-in utilities.
- **Data Integration**: Seamlessly integrate data from multiple sources into time-series databases.
- **Real-time Processing**: Handle streaming data with batch processing capabilities.
- **Data Validation**: Ensure data quality through schema validation and type checking.

## Getting Started

Ready to start using the Unity SDK? Check out our [Installation Guide](02-install.md) and [Quickstart Tutorial](03-quickstart.md).
