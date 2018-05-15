class <%= class_name.underscore.camelize %> < ActiveRecord::Migration[5.0]
  def self.up<% attributes.each do |csv_file| %>
    CSVImporter.import!("<%=csv_file.name%>")<%- end %>
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
