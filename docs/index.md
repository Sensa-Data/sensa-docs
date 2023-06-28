# SDM API

For full documentation visit [mkdocs.org](https://www.mkdocs.org).

## Endpoints

* `IngestOne` - Single record upload.
* `IngestMany` - Bulk records upload.


## Usage



#### With a title

``` py title="bubble_sort.py"
def test_data():
    record=[]
    for i in range(number_of_records_per_write):
         record.append({
            "system": "Test_system_1"})
```

#### With line numbers

``` py linenums="1"
def test_data():
    record=[]
    for i in range(number_of_records_per_write):
         record.append({
            "system": "Test_system_1"})
```
#### Highlighting lines

``` py hl_lines="2 3"
def test_data():
    record=[]
    for i in range(number_of_records_per_write):
         record.append({
            "system": "Test_system_1"})
```