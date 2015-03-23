require 'rails_helper'

RSpec.describe UTC do

  describe '.parse' do
    let(:date) { Time.utc(2015, 03, 01) } # 1st March, 2015 UTC
    let(:datetime_hours_only) { Time.utc(2015, 03, 01, 10) } # 10:00:00 1st March, 2015 UTC
    let(:datetime_hours_minutes_only) { Time.utc(2015, 03, 01, 10, 15) } # 10:15:00 1st March, 2015 UTC
    let(:datetime) { Time.utc(2015, 03, 01, 10, 15, 17) } # 10:15:17 1st March, 2015 UTC

    it 'converts 01.03.2015' do
      expect(UTC.parse('01.03.2015')).to eq(date)
    end

    it 'converts 01.03.2015 10' do
      expect(UTC.parse('01.03.2015 10')).to eq(datetime_hours_only)
    end

    it 'converts 01.03.2015 10:15' do
      expect(UTC.parse('01.03.2015 10:15')).to eq(datetime_hours_minutes_only)
    end

    it 'converts 01.03.2015 10:15:17' do
      expect(UTC.parse('01.03.2015 10:15:17')).to eq(datetime)
    end

    it 'converts 2015-03-01' do
      expect(UTC.parse('2015-03-01')).to eq(date)
    end

    it 'converts 2015-03-01 10' do
      expect(UTC.parse('2015-03-01 10')).to eq(datetime_hours_only)
    end

    it 'converts 2015-03-01 10:15' do
      expect(UTC.parse('2015-03-01 10:15')).to eq(datetime_hours_minutes_only)
    end

    it 'converts 2015-03-01 10:15:17' do
      expect(UTC.parse('2015-03-01 10:15:17')).to eq(datetime)
    end

    it 'converts 2015 March 01' do
      expect(UTC.parse('2015 March 01')).to eq(date)
    end

    it 'converts 2015 March 01 10' do
      expect(UTC.parse('2015 March 01 10')).to eq(datetime_hours_only)
    end

    it 'converts 2015 March 01 10:15' do
      expect(UTC.parse('2015 March 01 10:15')).to eq(datetime_hours_minutes_only)
    end

    it 'converts 2015 March 01 10:15:17' do
      expect(UTC.parse('2015 March 01 10:15:17')).to eq(datetime)
    end
  end
end
