import requests
import json
import re

def get_datasets_for(*dataset_ids):
  datasets = list()
  for dataset_id in dataset_ids:
    api_url = "http://localhost:4000/api/v1/exports/" + str(dataset_id)
    # api_url = "http://data.energytransitionmodel.com/api/v1/exports/" + str(dataset_id)
    response = requests.get(api_url)
    data = response.json()
    datasets.append(data)
  return datasets

def group_user_inputs(datasets, interface_elements):
    gathered_values = dict()
    for dataset in datasets:
        if not dataset: continue
        for element in interface_elements:
            gathered_values[element.key] = gathered_values.get(element.key, [])
            if type(element.method) == dict:
                weight = 1.0
                for key in element.method['weighted_average']:
                    weight *= dataset[0][key]
                gathered_values[element.key].append((dataset[0][element.key], weight))
            else:
                gathered_values[element.key].append(dataset[0][element.key])
    return gathered_values

def add_data_to_elements(data, elements):
    for element in elements:
        for key in data:
            if element.key == key:
                element.data = data.get(key)
    return elements

def collect_names(datasets):
    dataset_areas = [dataset[0].get('area', '') for dataset in datasets]
    dataset_names = ", ".join([name[name.index('_')+1:].capitalize() for name in dataset_areas])
    return dataset_names
