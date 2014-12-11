require 'rails_helper'

module StatsHelper
  def self.generate_values(count, options = {})
    count.times do |i|
      FactoryGirl.create(:value, item: options[:item], value: (i + 1).to_f, timestamp: Time.parse('01-01-2014 00:00:00 UTC') + i.days)
    end
  end
end

RSpec.describe Stats::Forecast, type: :model do
  let(:item) { FactoryGirl.create(:item) }
  
  describe '#series_quantities' do
    let(:result) { subject.send(:series_quantities) }

    context 'by days' do
      subject { Stats::Forecast.new(item, period: :day, from: Time.parse('01-01-2014 00:00:00 UTC'), to: Time.parse('05-01-2014 00:00:00 UTC')) }
      before { StatsHelper.generate_values(5, item: item) }
      it 'generates list of dates for time series' do
        expect(result).to eq({ '2014-01-01' => 1.0, '2014-01-02' => 2.0, '2014-01-03' => 3.0, '2014-01-04' => 4.0, '2014-01-05' => 5.0 })
      end
    end

    context 'by months' do
      subject { Stats::Forecast.new(item, period: :month, from: Time.parse('01-01-2014 00:00:00 UTC'), to: Time.parse('01-03-2014 00:00:00 UTC')) }
      before { StatsHelper.generate_values(5, item: item) }
      it 'generates list of dates for time series' do
        expect(result).to eq({ '2014-01' => 15.0 })
      end
    end
  end

  describe '#series_dates' do
    let(:result) { subject.send(:series_dates) }

    context 'by days' do
      subject { Stats::Forecast.new(item, period: :day, from: Time.parse('01-01-2014 00:00:00 UTC'), to: Time.parse('05-01-2014 00:00:00 UTC')) }
      it 'generates list of dates for time series' do
        expect(result).to eq ['2014-01-01', '2014-01-02', '2014-01-03', '2014-01-04', '2014-01-05']
      end
    end

    context 'by months' do
      subject { Stats::Forecast.new(item, period: :month, from: Time.parse('01-01-2014 00:00:00 UTC'), to: Time.parse('01-03-2014 00:00:00 UTC')) }
      it 'generates list of dates for time series' do
        expect(result).to eq ['2014-01', '2014-02', '2014-03']
      end
    end
  end

  describe '#series' do
    let(:result) { subject.send(:series) }

    context 'by days' do
      subject { Stats::Forecast.new(item, period: :day, from: Time.parse('01-01-2014 00:00:00 UTC'), to: Time.parse('05-01-2014 00:00:00 UTC')) }
      before { StatsHelper.generate_values(5, item: item) }
      it 'generates list of dates for time series' do
        expect(result).to eq [1.0, 2.0, 3.0, 4.0, 5.0]
      end
    end

    context 'by months' do
      subject { Stats::Forecast.new(item, period: :month, from: Time.parse('01-01-2014 00:00:00 UTC'), to: Time.parse('01-03-2014 00:00:00 UTC')) }
      before { StatsHelper.generate_values(5, item: item) }
      it 'generates list of dates for time series' do
        expect(result).to eq [15.0, 0.0, 0.0]
      end
    end
  end

  describe '#calculate' do
    let(:result) { subject.send(:calculate) }

    context 'by days' do
      subject { Stats::Forecast.new(item, period: :day, depth: 3, from: Time.parse('01-01-2014 00:00:00 UTC'), to: Time.parse('05-01-2014 00:00:00 UTC')) }
      before { StatsHelper.generate_values(5, item: item) }
      it 'generates list of predictions' do
        expect(result).to eq({'2014-01-06' => 6.0, '2014-01-07' => 7.0, '2014-01-08' => 8.0})
      end
    end

    context 'by month' do
      subject { Stats::Forecast.new(item, period: :month, depth: 1, from: Time.parse('01-01-2014 00:00:00 UTC'), to: Time.parse('01-03-2014 00:00:00 UTC')) }
      before { StatsHelper.generate_values(5, item: item) }
      it 'generates list of predictions' do
        expect(result).to eq({'2014-04' => 6.123380718525147})
      end
    end
  end
end
