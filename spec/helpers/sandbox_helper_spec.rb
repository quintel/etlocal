require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the SandboxHelper. For example:
#
# describe SandboxHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe SandboxHelper, type: :helper do
  describe 'format_result' do
    context 'formatting 1.0' do
      it 'returns "1.0"' do
        expect(helper.format_result(1.0)).to eq('1.0')
      end
    end

    context 'formatting 1000.0' do
      it 'returns "1,000.0"' do
        expect(helper.format_result(1000.0)).to eq('1,000.0')
      end
    end

    context "formatting 'hello'" do
      it 'returns "&quot;hello&quot;"' do
        expect(helper.format_result('hello')).to eq('&quot;hello&quot;')
      end
    end

    context "formatting '<strong>" do
      it 'escapes HTML entities' do
        expect(helper.format_result('<strong>'))
          .to eq('&quot;&lt;strong&gt;&quot;')
      end
    end

    context "formatting [1.0, 2.0, [3.0, 4.0], 5.0]" do
      it 'returns a formatted array' do
        expected = <<-EXPECTED.strip_heredoc.rstrip
          [
            1.0,
            2.0,
            [
              3.0,
              4.0
            ],
            5.0
          ]
        EXPECTED

        expect(helper.format_result([1.0, 2.0, [3.0, 4.0], 5.0]))
          .to eq(expected)
      end
    end
  end
end
