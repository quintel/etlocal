
def average(array):
  return sum(array) / len(array)

def weighted_average(array):
  '''
  If the denominator is zero this means we can't calculate a weighted average.
  Instead calculate the 'normal' average.
  '''
  numerator = sum(x*y for (x, y) in array)
  denominator = sum(y for (x,y) in array)
  try:
    return numerator / denominator
  except ZeroDivisionError:
    return average((x for x,y in array))


def combined_values(interface_data):
  for each in interface_data:
    if all(value is None for value in each.data):
      each.combined_data = None
    elif each.method == 'sum':
      each.combined_data = round_val(sum(each.data))
    elif each.method == 'average':
      each.combined_data = round_val(average(each.data))
    elif each.method == 'min':
      each.combined_data = round_val(min(each.data))
    elif each.method == 'max':
      each.combined_data = round_val(max(each.data))
    elif type(each.method) == dict:
      each.combined_data = round_val(weighted_average(each.data))
    else:
      raise ValueError('Unknown combination method \'{}\' for \'{}\''.format(each.method, each.key))


def round_val(value):
  return round(value, 6)


def flexible_shares(interface_data):
  for each in interface_data:
    if each.flexible:
      total = 0.0
      for share in each.share_group:
        total += [ele.combined_data for ele in interface_data if ele.key == share][0]
      each.combined_data = round(1 - total, 6)
