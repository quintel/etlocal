# Defaults

This directory should contain a "data.csv" containing default data for each
region, and "commits.yml" describing the commits which should be created.

CSV files must include the attributes `geo_id` and `geo_name`, followed by all
the values needed to fully-initialize each region. For example:

```csv
geo_id,geo_name,number_of_residences,number_of_inhabitants,has_agiculture,...
BU16800000,Annen,1000,3800,0,...
BU16800500,Schipborg,800,2100,1,...
```

The commits.yml file describes the commits which should be created for each
region:

```yaml
---
- fields:
  - number_of_residences
  - number_of_inhabitants
  message:
    Add population data sourced from ...
- fields:
  - has_agriculture
  message:
    Set agiculture availability based on data from ...

```

Quintel-created files for NL regions may be found in
"Dropbox/Development/etlocal_defaults".
