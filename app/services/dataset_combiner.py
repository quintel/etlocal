import os
import sys
from functools import reduce
from pathlib import Path
from dataset_combiner import interface_element_collector
from dataset_combiner import dataset_collector
from dataset_combiner import calculate
from dataset_combiner import user_arguments
from dataset_combiner import migration

geo_id, name, dataset_ids = user_arguments.process(sys.argv[1:])
etlocal_root = str(Path(__file__).resolve().parents[2])

interface_files = interface_element_collector.files_from(etlocal_root + '/config/interface_elements')
interface_data = interface_element_collector.data_from(interface_files)

datasets = dataset_collector.get_datasets_for(*dataset_ids)
grouped_inputs = dataset_collector.group_user_inputs(datasets, interface_data)
dataset_collector.add_data_to_elements(grouped_inputs, interface_data)

dataset_names = dataset_collector.collect_names(datasets)


calculate.combined_values(interface_data)
calculate.rounded_values(interface_data)
calculate.flexible_shares(interface_data)

migration_name = migration.create_for(geo_id, name)
migration_path, migration_file, migration_folder = migration.return_file_folder_path(migration_name)

csvData = migration.generate_rows(geo_id, name, interface_data)

migration.generate_data_csv((etlocal_root, migration_path, migration_folder), csvData)
migration.generate_commits((etlocal_root, migration_path, migration_folder), dataset_names)

if name:
  migration.enable_new_datasets((etlocal_root, migration_path, migration_file))