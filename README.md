# OHDSI WhiteRabbit Docker

A Dockerized build of [OHDSI **WhiteRabbit**](https://github.com/OHDSI/WhiteRabbit) with:

- **CLI mode** (default)
- **GUI mode** (optional via Xvfb + VNC)


## Quick start (end‑user guide)

### 1) Pull the image from Docker Hub

```bash
docker pull edence/whiterabbit-container:main
```

### 2) Run WhiteRabbit in CLI mode (default)

Create a WhiteRabbit .ini file and pass this to the container:. The .ini file content can vary depending on what the source database/file format is, but generally has the following format:

```
WORKING_FOLDER = /data                 # Path to the folder where all output will be written
DATA_TYPE = PostgreSQL                 # "Delimited text files", "MySQL", "Oracle", "SQL Server", "PostgreSQL", "MS Access", "Redshift", "BigQuery", "Azure", "Teradata", "SAS7bdat"
SERVER_LOCATION = 127.0.0.1/db_name    # Name or address of the server. For Postgres, add the database name
USER_NAME = postgres                   # User name for the database 
PASSWORD = supersecret                 # Password for the database 
DATABASE_NAME = schema_name            # Name of the data schema used 
DELIMITER = ,                          # The delimiter that separates values
TABLES_TO_SCAN = *                     # Comma-delimited list of table names to scan. Use "*" (asterix) to include all tables in the database
SCAN_FIELD_VALUES = yes                # Include the frequency of field values in the scan report? "yes" or "no"
MIN_CELL_COUNT = 5                     # Minimum frequency for a field value to be included in the report
MAX_DISTINCT_VALUES = 1000             # Maximum number of distinct values per field to be reported
ROWS_PER_TABLE = 100000                # Maximum number of rows per table to be scanned for field values
CALCULATE_NUMERIC_STATS = no           # Include average, standard deviation and quartiles in the scan report? "yes" or "no"
NUMERIC_STATS_SAMPLER_SIZE = 500       # Maximum number of rows used to calculate numeric statistics
```

See [https://ohdsi.github.io/WhiteRabbit/WhiteRabbit.html#Source_Data](https://ohdsi.github.io/WhiteRabbit/WhiteRabbit.html#Source_Data) for some more information about how to format the parameters for the different sources.

#### Example 1: scan folder of .csv files
In the following example, there is a _data_ sub-directory with a collection of .csv files, and an .ini file _csv-source.ini_ that defines the parameters:

```
csv-source.ini
└── data
    ├── allergies.csv
    ├── careplans.csv
    ├── conditions.csv
    ├── encounters.csv
    ├── imaging_studies.csv
    ├── immunizations.csv
    ├── medications.csv
    ├── observations.csv
    ├── organizations.csv
    ├── patients.csv
    ├── procedures.csv
    └── providers.csv
```
The content of _csv-source.ini_:

```
WORKING_FOLDER = /data
DATA_TYPE = Delimited text files
DELIMITER = ,
TABLES_TO_SCAN = *
SCAN_FIELD_VALUES = yes
MIN_CELL_COUNT = 5
MAX_DISTINCT_VALUES = 1000
ROWS_PER_TABLE = 100000
CALCULATE_NUMERIC_STATS = no
NUMERIC_STATS_SAMPLER_SIZE = 500
```

**macOS / Linux:**

```bash
docker run --rm \
  -v "$(pwd)/data:/data:rw" \
  -v "$(pwd)/csv-source.ini:/config/csv-source.ini:ro" \
  edence/whiterabbit-container:main \
  gui -ini /config/csv-source.ini
```

**Windows (PowerShell):**

```powershell
docker run --rm `
  -v "${PWD}\data:/data:rw" `
  -v "${PWD}\csv-source.ini:/config/csv-source.ini:ro" `
  edence/whiterabbit-container:main `
  gui -ini /config/csv-source.ini
```

**Windows (CMD):**

```bat
docker run --rm ^
  -v "%cd%\data:/data:rw" ^
  -v "%cd%\csv-source.ini:/config/csv-source.ini:ro" ^
  edence/whiterabbit-container:main ^
  gui -ini /config/csv-source.ini
```

The resulting _ScanReport.xlsx_ file will be written to the same directory as the .csv files, so make sure you have write access to that directory.

If you only want to include a sub-set of the .csv files, change the line for TABLES_TO_SCAN to the following format, listing the file names to include separated by comma:

```
TABLES_TO_SCAN = patients.csv,encounters.csv,conditions.csv,procedures.csv,medications.csv
```

#### Example 2: scan tables in a PostgreSQL database schema
In the following example, there is a _data_ sub-directory available for writing the resulting _ScanReport.xlsx_ file, and an .ini file _postgres-source.ini_ that defines the parameters:
 
```
postgres-source.ini
└── data
```
The content of _postgres-source.ini_:

```
WORKING_FOLDER = /data
DATA_TYPE = PostgreSQL
SERVER_LOCATION = 192.168.1.123:5432/postgres
USER_NAME = postgres
PASSWORD = somestrongpassword 
DATABASE_NAME = source_schema
DELIMITER = ,
TABLES_TO_SCAN = *
SCAN_FIELD_VALUES = yes
MIN_CELL_COUNT = 5
MAX_DISTINCT_VALUES = 1000
ROWS_PER_TABLE = 100000
CALCULATE_NUMERIC_STATS = no
NUMERIC_STATS_SAMPLER_SIZE = 500
```

**macOS / Linux:**

```bash
docker run --rm \
  -v "$(pwd)/data:/data:rw" \
  -v "$(pwd)/postgres-source.ini:/config/postgres-source.ini:ro" \
  edence/whiterabbit-container:main \
  gui -ini /config/postgres-source.ini
```

**Windows (PowerShell):**

```powershell
docker run --rm `
  -v "${PWD}\data:/data:rw" `
  -v "${PWD}\postgres-source.ini:/config/postgres-source.ini:ro" `
  edence/whiterabbit-container:main `
  gui -ini /config/postgres-source.ini
```

**Windows (CMD):**

```bat
docker run --rm ^
  -v "%cd%\data:/data:rw" ^
  -v "%cd%\postgres-source.ini:/config/postgres-source.ini:ro" ^
  edence/whiterabbit-container:main ^
  gui -ini /config/postgres-source.ini
```

The resulting _ScanReport.xlsx_ file will be written directory specified (_data_ in this example), so make sure you have write access to that directory.

If you only want to include a sub-set of the tables, change the line for TABLES_TO_SCAN to the following format, listing the table names to include separated by comma:

```
TABLES_TO_SCAN = patient,blood_samples,comorb
```

#### Other examples
There are a few other examples of .ini files in the WhiteRabbit GitHub repop: [https://github.com/OHDSI/WhiteRabbit/tree/master/iniFileExamples](https://github.com/OHDSI/WhiteRabbit/tree/master/iniFileExamples)


## GUI mode (optional)

GUI mode runs WhiteRabbit in a headless X server with optional VNC.

### Run GUI with VNC

**macOS / Linux:**

```bash
docker run --rm -p 5900:5900 \
  -e ENABLE_VNC=1 \
  -e VNC_PASSWORD=ohdsi \
  edence/whiterabbit-container:main gui
```

**Windows (PowerShell):**

```powershell
docker run --rm -p 5900:5900 `
  -e ENABLE_VNC=1 `
  -e VNC_PASSWORD=ohdsi `
  edence/whiterabbit-container:main gui
```

**Windows (CMD):**

```bat
docker run --rm -p 5900:5900 ^
  -e ENABLE_VNC=1 ^
  -e VNC_PASSWORD=ohdsi ^
  edence/whiterabbit-container:main gui
```

Then connect using any VNC client:

```
Host: localhost:5900
Password: ohdsi
```


# License & attribution

[WhiteRabbit](https://ohdsi.github.io/WhiteRabbit/index.html) is an [OHDSI](https://ohdsi.org) tool.  
Please follow the OHDSI project’s licensing and attribution requirements.
