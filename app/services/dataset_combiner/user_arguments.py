def process(args):
  geo_id = args[0]
  name = False
  try:
    int(args[1])
    dataset_ids = tuple(args[1:])
  except ValueError:
    name = args[1]
    dataset_ids = tuple(args[2:])
  return geo_id, name, dataset_ids