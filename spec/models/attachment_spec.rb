require 'rails_helper'

RSpec.describe Attachment, type: :model do
  let(:item) { FactoryGirl.create(:item) }
  let(:file) { "#{Rails.root}/spec/fixtures/attachments/#{filename}" }
  let(:attachment) { Attachment.new(item, file) }
  let(:action) { attachment.process }

  shared_examples 'any attachment' do
    it 'reads 5 of 6 records' do
      expect { action }.to change(Value, :count).by(5)
    end

    it 'reads correct data' do
      action
      expect(item.values.pluck(:timestamp, :value)).to eq([
        [UTC.parse('01.01.2015'), 10.0],
        [UTC.parse('02.01.2015'), 9.0],
        [UTC.parse('03.01.2015'), 11.11],
        [UTC.parse('04.01.2015'), 0.0],
        [UTC.parse('05.01.2015'), 0.0],
      ])
    end

    it 'sets correct statistics' do
      action
      expect(attachment.total_lines).to eq(6)
      expect(attachment.processed_lines).to eq(5)
      expect(attachment.not_processed_lines).to eq(1)
    end
  end

  context 'col sep ;' do
    context 'no quotes' do
      context 'float .' do
        let(:filename) { 'col_sep_semicolon/no_quotes/float_point.csv' }
        it_behaves_like 'any attachment'
      end

      context 'float ,' do
        let(:filename) { 'col_sep_semicolon/no_quotes/float_comma.csv' }
        it_behaves_like 'any attachment'
      end
    end

    context 'quotes' do
      context 'float .' do
        let(:filename) { 'col_sep_semicolon/quotes/float_point.csv' }
        it_behaves_like 'any attachment'
      end

      context 'float ,' do
        let(:filename) { 'col_sep_semicolon/quotes/float_comma.csv' }
        it_behaves_like 'any attachment'
      end
    end
  end

  context 'col sep ,' do
    context 'no quotes' do
      context 'float .' do
        let(:filename) { 'col_sep_comma/no_quotes/float_point.csv' }
        it_behaves_like 'any attachment'
      end

      context 'float ,' do
        let(:filename) { 'col_sep_comma/no_quotes/float_comma.csv' }
        it_behaves_like 'any attachment'
      end
    end

    context 'quotes' do
      context 'float .' do
        let(:filename) { 'col_sep_comma/quotes/float_point.csv' }
        it_behaves_like 'any attachment'
      end

      context 'float ,' do
        let(:filename) { 'col_sep_comma/quotes/float_comma.csv' }
        it_behaves_like 'any attachment'
      end
    end
  end

  context 'horizontal' do
    let(:filename) { 'horizontal/comma.csv' }
    it_behaves_like 'any attachment'
  end

end
