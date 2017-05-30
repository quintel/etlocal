module MenuHelper
  def menu_structure
    @menu_structure ||= YAML.load_file(Rails.root.join('config', 'menu.yml'))
  end
end
