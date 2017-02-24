class Source < ApplicationRecord
  has_attached_file :source_file

  has_many :commits

  # Validates attachments content types. The content types are in alphabetical
  # order. Please stick to that.
  validates_attachment_content_type :source_file, content_type: [
    'application/octet-stream',
    'application/pdf',
    'application/vnd.ms-excel',
    'application/vnd.ms-office',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/x-ole-storage',
    'application/xls',
    'application/xlsx',
    'application/zip'
  ]
end
