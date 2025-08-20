# Data Validation Before Exporting to UnityDB

!!! note "Why validate before exporting?"

    Before exporting data to **Unity DB**, it's strongly recommended to validate and format your data using:

    ```python
    model_utils.apply_data_types(df, validation_model)
    ```

    - **`df`**: a `pandas.DataFrame` containing the data to be exported.
    - **`validation_model`**: a Pydantic model that defines the expected structure, field names, and data types.

    This ensures the dataset strictly conforms to the required schema, preventing data integrity issues during export.

---

## Using Pydantic for Schema Validation

Validation schemas are defined using **[Pydantic](https://docs.pydantic.dev/)**, a Python library that enables:

- **Type checking**
- **Schema enforcement**
- **Automatic data parsing and conversion**

This makes your data pipelines more reliable and maintainable by catching structural issues early.

---

## Example: Water Quality Validation Schema
Here's a sample pydantic validation schema for water quality data:

```python
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field, field_validator
from typing_extensions import Annotated, Optional


class WaterQualityLabMeasurementsModel(BaseModel):
    DateTime: Annotated[datetime, Field(alias='DateTime [mm/dd/yy hh:mm]',
                                        json_schema_extra={'field_type': 'time'})]
    Site: Annotated[str, Field(alias='Site',
                               json_schema_extra={'field_type': 'tags'})]
    Unit: Annotated[str, Field(alias='Unit',
                               json_schema_extra={'field_type': 'tags'})]
    System: Annotated[str, Field(alias='System',
                                 json_schema_extra={'field_type': 'tags'})]
    Equipment_Unit: Annotated[str, Field(alias='Equipment Unit',
                                         json_schema_extra={'field_type': 'tags'})]
    Sub_Unit: Annotated[Optional[str], Field(alias='Sub Unit',
                                             coerce_numbers_to_str=True,
                                             json_schema_extra={'field_type': 'tags'})]
    TAN: Annotated[float | None, Field(alias='TAN[mg/l]',
                                json_schema_extra={'field_type': 'value'})]
    NO2_N: Annotated[float | None, Field(alias='NO2-N  [mg/l]',
                                json_schema_extra={'field_type': 'value'})]
    NO3_N: Annotated[float | None, Field(alias='NO3-N [mg/l]',
                                json_schema_extra={'field_type': 'value'})]
    Turbidity: Annotated[float | None, Field(alias='Turbidity [FAU]',
                                json_schema_extra={'field_type': 'value'})]
    alkalinity: Annotated[float | None, Field(alias='alkalinity [mg/l]',
                                json_schema_extra={'field_type': 'value'})]
    pH: Annotated[float | None, Field(alias='pH []',
                                json_schema_extra={'field_type': 'value'})]
    TSS: Annotated[float | None, Field(alias='TSS[mg/l]',
                                json_schema_extra={'field_type': 'value'})]
    SS: Annotated[float | None, Field(alias='SS [mg/l]',
                                json_schema_extra={'field_type': 'value'})]
    UVT10: Annotated[float | None, Field(alias='UVT10[%]',
                                json_schema_extra={'field_type': 'value'})]
    Salinity: Annotated[float | None, Field(alias='Salinity [ppt]',
                                json_schema_extra={'field_type': 'value'})]
    Visibility: Annotated[float | None, Field(alias='Visibility [meter]',
                                json_schema_extra={'field_type': 'value'})]
    Temperature: Annotated[float | None, Field(alias='Temperature [C]',
                                json_schema_extra={'field_type': 'value'})]
    Spedevann: Annotated[float | None, Field(alias='Spedevann [m3/hour]',
                                json_schema_extra={'field_type': 'value'})]
    CO2: Annotated[float | None, Field(alias='CO2 [mg/l]',
                                       json_schema_extra={'field_type': 'value'})]
    Comments: Annotated[str | None, Field(alias='Comments',
                                          json_schema_extra={
                                              'field_type': 'value'})]
```
```python
    model_utils.apply_data_types(df, validation_model=WaterQualityLabMeasurementsModel)
```
!!! note "Note"

    The `field_type` key in `json_schema_extra` is used to indicate **how each field should be interpreted during data ingestion**.

    - `**'field_type': 'value'**` represent **categorical** identifiers (e.g., Unit, Site, system).
    - `**'field_type': 'tags'**` represent **numerical** measurements (e.g., CO₂ Turbidity, pH).
