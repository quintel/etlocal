
def average(array):
  return sum(array) / len(array)

def weighted_average(array):
  numerator = sum(x*y for (x, y) in array)
  denominator = sum(y for (x,y) in array)
  try:
    return numerator / denominator
  except ZeroDivisionError:
    return 0.0

def combined_values(interface_data):
  for each in interface_data:
    try:
      if each.method == 'sum':
        each.combined_data = sum(each.data)
      elif each.method == 'average':
        each.combined_data = average(each.data)
      elif each.method == 'min':
        each.combined_data = min(each.data)
      elif each.method == 'max':
        each.combined_data = max(each.data)
      elif type(each.method) == dict:
        each.combined_data = weighted_average(each.data)
      else:
        return 'Unknown combination method \'{}\' for \'{}\''.format(each.method, each.key)
    except:
      print(f"\nWARNING! Combination method couldn't be applied, presumably because one of the values for {each} is None. Combined value has been set to zero.")
      each.combined_data = 0

def rounded_values(interface_data):
  for each in interface_data:
    each.combined_data = round(each.combined_data, 6)

def flexible_shares(interface_data):
  for each in interface_data:
    if each.flexible:
      total = 0.0
      for share in each.share_group:
        total += [ele.combined_data for ele in interface_data if ele.key == share][0]
      each.combined_data = round(1 - total, 6)