import subprocess
import re
import csv

def create_for(geo_id, name):
  if name:
    migration_name = '{}_{}'.format(geo_id, name)
  else:
    migration_name = geo_id
  proc = subprocess.Popen("bundle exec rails generate data_migration {}".format(migration_name), shell=True ,stdout=subprocess.PIPE)
  while True:
    record = proc.stdout.readline()
    if not record:
      break
    match = re.search(r'(?<=db/migrate/)(.*)(?=\.rb)', str(record))
    if match:
      migration = match.group()
      break
  proc.wait()
  return migration

def return_file_folder_path(migration):
  migration_path = 'db/migrate'
  migration_file = '{}.rb'.format(migration)
  migration_folder = '{}'.format(migration)
  return migration_path, migration_file, migration_folder

def generate_rows(geo_id, name, interface_data):
  key_row = ['geo_id']
  element_keys = [element.key for element in interface_data]
  key_row.extend(element_keys)
  data_row = [geo_id]
  element_data = [element.combined_data for element in interface_data]
  data_row.extend(element_data)
  if name:
    key_row.insert(1, 'name')
    data_row.insert(1, name)
  return [key_row, data_row]

def generate_data_csv(path, data):
  with open('{}/{}/{}/data.csv'.format(*path), 'w', encoding='utf-8') as csvFile:
      writer = csv.writer(csvFile)
      writer.writerows(data)
  csvFile.close()

def generate_commits(path, dataset_names):
  with open('{}/{}/{}/commits.yml'.format(*path,), 'w') as commits:
    commit_file = "---\n- fields:\n  - :all\n  message:\n    \"Optelling van de volgende gebieden: {}\"".format(dataset_names)
    commits.write(commit_file)

def enable_new_datasets(path):
  with open('{}/{}/{}'.format(*path), 'r+') as importer:
    ruby_script = importer.read()
    enable_new_dataset = ruby_script.replace('commits_path)', 'commits_path, create_missing_datasets: true)')
    importer.seek(0)
    importer.truncate()

    importer.write(enable_new_dataset)
    importer.truncate()
    importer.close()

