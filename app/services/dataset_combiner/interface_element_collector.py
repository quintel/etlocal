import yaml
import os


class Interface_element:
  def __init__(self, key, flexible=False, data=list()):
    self.key = key
    self.flexible = flexible
    self.data = data

  def __str__(self):
    return '{}'.format(self.key)

# returns all file paths of interface_element .yml files
def files_from(path):
  combination_files = list()
  for root, dirs, files in os.walk(path):
    for file in files:
      if file.endswith('.yml'):
        combination_files.append(root + "/" + file)
  return combination_files

''' from each interface_element.yml, extract the interface elements in the file, their dataset combination method,
whether they are 'flexible' and if so, the share group they are in
Return a list containing all interface elements, with combination method, flexible and share group as attributes'''
def data_from(interface_files):
  interface_elements = list()
  # open each interface_element.yml
  for file in interface_files:
    with open(file, 'r') as f:
      interface_file = yaml.load(f)
    for header in interface_file['groups']:
      # loop over each interface element ('item') in each 'group'
      for item in header['items']:
        element = Interface_element(item.get('key'))
        # check if item if a flexible share, if so add an attribute 'share_group' containing all other shares
        if item.get('flexible', False):
          element.flexible = True
          element.share_group = [share['key'] for share in header['items'] if share['key'] != element.key]
        # check if combination method is specified at the 'group' level or at the 'item' level
        # if at 'group' level, apply that method to all items in the group
        if header.get('combination_method', False):
          method = header['combination_method']
        else:
        # if the combination method is specified at the 'item' level, set the appropriate attribute
        # if no method is specified, set the default 'sum' method
          method = item.get('combination_method', 'sum')
        element.method = method
        interface_elements.append(element)
  return interface_elements
