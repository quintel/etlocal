class Dataset < ActiveRecord::Base
  attr_accessor :commit_message

  has_paper_trail only: [:updated_at], meta: {
    commit_message: :commit_message
  }

  has_attached_file :dataset_file

  validates_presence_of :title
  validates_presence_of :commit_message, unless: :new_record?

  validates_attachment_content_type :dataset_file, content_type: [
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
