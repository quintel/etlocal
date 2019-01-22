def process(args):
  for arg in args:
    if arg.startswith('geo_id='):
      geo_id = arg.replace('geo_id=', '')
    if arg.startswith('name='):
      name = arg.replace('name=', '')
    if arg.startswith('migration_name='):
      migration_name = arg.replace('migration_name=', '').replace(" ", "_")
    if arg.startswith('dataset_ids='):
      dataset_ids = arg.replace('dataset_ids=', '')
      dataset_ids = tuple( int(id) for id in dataset_ids.split(',') )
  return geo_id, name, migration_name, dataset_ids
