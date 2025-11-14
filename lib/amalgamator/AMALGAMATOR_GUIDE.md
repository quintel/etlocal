# Amalgamator Usage Guide

The Amalgamator is a tool for combining multiple regional datasets into larger aggregated datasets, or for separating datasets by subtracting one from another. This is commonly used to create provincial or RES-region datasets from municipality data.

## Overview

The Amalgamator provides two main operations:

1. **Combining**: Merge multiple datasets (e.g., municipalities) into a single larger dataset (e.g., province)
2. **Separating**: Subtract one dataset from another to create a residual dataset

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

### Example 3: Update Multiple Provinces

For batch operations combining multiple regions, execute the rake task multiple times in sequence:

```bash
# Province 1 - Groningen
rails dataset:combine \
  target_dataset_geo_id=PV20 \
  source_data_year=2023 \
  source_dataset_geo_ids=GM0014,GM0037,GM0047,GM0765,GM1895,GM1950 \
  target_area_name=Groningen \
  target_parent_name=nl2023 \
  migration_slug=update_2023

# Province 2 - Fryslan
rails dataset:combine \
  target_dataset_geo_id=PV21 \
  source_data_year=2023 \
  source_dataset_geo_ids=GM0059,GM0060,GM0072,GM0074 \
  target_area_name=Fryslan \
  target_parent_name=nl2023 \
  migration_slug=update_2023

# Continue for remaining provinces...
```
