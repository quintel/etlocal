# Amalgamator Usage Guide

The Amalgamator is a tool for combining multiple regional datasets into larger aggregated datasets, or for separating datasets by subtracting one from another. This is commonly used to create provincial or RES-region datasets from municipality data.

## Overview

The Amalgamator provides three main operations:

1. **Combining**: Merge multiple datasets (e.g., municipalities) into a single larger dataset (e.g., province)
2. **Batch combining**: Combine into many target datasets at once (e.g., all municipalities into all
   provinces, or into all RES regions), based on a mapping CSV
3. **Separating**: Subtract one dataset from another to create a residual dataset

### Key Features

- Automatically combines data based on configured combination methods (sum, average, weighted average, min, max)
- Validates data year consistency across source datasets
- Generates migration files with combined data for easy import
- Handles flexible shares that need to sum to 100%

## Basic Usage

The Amalgamator is accessed through rake tasks:

```bash
# Combine datasets
rails dataset:combine \
  target_dataset_geo_id=PV20 \
  source_data_year=2023 \
  source_dataset_geo_ids=GM0014,GM0037,GM0047,GM0765 \
  target_area_name=Groningen \
  target_parent_name=nl2023 \
  migration_slug=update_2023

# Combine into all provinces at once, based on a mapping of municipalities onto provinces
rails dataset:combine_all \
  mapping_file='../etdataset/pipelines/config/CBS Gebieden in Nederland 2023 - ETM version.csv' \
  source_geo_id_column='gemeenten|Code' \
  target_geo_id_column='Provincies|Code' \
  source_data_year=2023 \
  target_parent_name=nl2023 \
  migration_slug=heat_pump_update

# Separate datasets (subtract one from another)
rails dataset:separate \
  target_dataset_geo_id=PV20 \
  source_dataset_geo_ids=GM0014 \
  source_data_year=2023 \
  migration_slug=remove_groningen
```

## How It Works

### Combination Methods

The Amalgamator combines data based on the `combination_method` set for each interface item:

- **sum** (default): Adds values across all datasets
- **average**: Calculates arithmetic mean
- **weighted_average**: Weighted mean based on specified weighing keys
- **min**: Takes minimum value
- **max**: Takes maximum value

Boolean values use:
- **min**: Returns true only if all are true
- **max**: Returns true if any are true

### Process Flow

1. **Validation**: Checks all required parameters and validates dataset data years
2. **Data Combination**: Processes each interface item according to its combination method
3. **Flexible Share Adjustment**: Adjusts flexible shares to ensure group totals equal 100%
4. **Rounding**: Rounds all values to 8 decimal places
5. **Export**: Creates migration file with combined data and commits file

### Output Files

The amalgamation creates:

1. **Migration file**: `db/migrate/TIMESTAMP_geo_id_area_name_slug.rb`
2. **Data directory**: Contains:
   - `data.csv`: Combined dataset values
   - `commits.yml`: List of source areas that were combined

## Examples

### Example 1: Combine Municipalities into a Province

```bash
# Combine 4 municipalities into Groningen province
rails dataset:combine \
  target_dataset_geo_id=PV20 \
  source_data_year=2023 \
  source_dataset_geo_ids=GM0014,GM0037,GM0047,GM0765 \
  target_area_name=Groningen \
  target_parent_name=nl2023 \
  migration_slug=update_2023
```

### Example 2: Separate a Municipality from a Province

```bash
# Subtract one municipality from a province
rails dataset:separate \
  target_dataset_geo_id=PV20 \
  source_dataset_geo_ids=GM0014 \
  source_data_year=2023 \
  migration_slug=remove_groningen
```

### Example 3: Combine into All Provinces or All RES Regions

Use `dataset:combine_all` instead of running `dataset:combine` once per region. It reads a mapping
CSV with one row per source region and groups the rows by target region, so the same file can be
used for provinces and for RES regions by pointing at a different target column.

```bash
# All municipalities into all 12 provinces
rails dataset:combine_all \
  mapping_file='../etdataset/pipelines/config/CBS Gebieden in Nederland 2023 - ETM version.csv' \
  source_geo_id_column='gemeenten|Code' \
  target_geo_id_column='Provincies|Code' \
  source_data_year=2023 \
  target_parent_name=nl2023 \
  migration_slug=heat_pump_update

# All municipalities into all 30 RES regions. The RES columns are addressed by position here,
# because their header contains a typographic apostrophe.
rails dataset:combine_all \
  mapping_file='../etdataset/pipelines/config/CBS Gebieden in Nederland 2023 - ETM version.csv' \
  source_geo_id_column=2 \
  target_geo_id_column=5 \
  source_data_year=2023 \
  target_parent_name=nl2023 \
  migration_slug=heat_pump_update
```

Columns are addressed either by part of their header (case-insensitive) or by their 1-based
position in the file. One migration is generated per target region, named after the geo-id and the
name of that region followed by the migration slug.

Before generating anything, the task checks that every source region has a dataset (a missing one
would silently drop out of the sum) and that no migration for the same target and slug exists yet
(Rails refuses to migrate two migrations with the same name).

Useful extra arguments:

- `dry_run=true`: report which regions would be combined, from which sources, without writing
- `only=PV20,PV21` / `except=PV20`: restrict the batch, e.g. to redo a single region
- `force=true`: replace migrations generated earlier for the same target and slug
- `allow_missing_sources=true`: continue when a source region has no dataset

The names and parents of the target datasets are taken from the existing datasets, so they keep
their current spelling. Pass `target_name_column` when the targets do not exist yet and their names
have to come from the mapping file.
