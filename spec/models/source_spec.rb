require 'rails_helper'

describe Source do
  it { should validate_attachment_content_type(:source_file).
        allowing('application/octet-stream',
                 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                 'application/vnd.ms-excel',
                 'application/vnd.ms-office',
                 'application/x-ole-storage',
                 'application/xls',
                 'application/xlsx',
                 'application/zip').
        rejecting('text/plain', 'text/xml') }
end
