class Source < ApplicationRecord
  has_attached_file :source_file

  has_many :dataset_edits

  validates_attachment_content_type :source_file, content_type: [
    'application/octet-stream',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.ms-office',
    'application/x-ole-storage',
    'application/xls',
    'application/xlsx',
    'application/zip'
  ]
end
