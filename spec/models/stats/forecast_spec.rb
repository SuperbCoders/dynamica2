require 'rails_helper'

RSpec.describe Stats::Forecast, type: :model do
  let(:item) { FactoryGirl.create(:item) }

  describe 'series generation methods' do
    describe '#series' do

      before do
        StatsHelper.generate_values(item: item, from: from, to: to, interval: 1.hour, value: 1)
      end

      subject do
        Stats::Forecast.new(item, period: period, from: from, to: to)
      end

      context 'period: hour' do
        let(:from) { UTC.parse('01.01.2014 00:00:00') }
        let(:to) { UTC.parse('01.01.2014 10:00:00') }
        let(:period) { :hour }
        let(:expected_result) { StatsHelper.generate_series(interval: 1.hour, value: 1, from: from, to: to) }

        it 'returns array of series' do
          expect(subject.series).to eq(expected_result)
        end
      end

      context 'period: day' do
        let(:from) { UTC.parse('01.01.2014 00:00:00') }
        let(:to) { UTC.parse('05.01.2014 23:59:59') }
        let(:period) { :day }
        let(:expected_result) { StatsHelper.generate_series(interval: 1.day, value: 24, from: from, to: to) }

        it 'returns array of series' do
          expect(subject.series).to eq(expected_result)
        end
      end

      context 'period: week' do
        let(:from) { UTC.parse('01.01.2014 00:00:00') }
        let(:to) { UTC.parse('05.01.2014 23:59:59') }
        let(:period) { :week }
        let(:expected_result) { StatsHelper.generate_series(interval: 1.week, value: 5 * 24, from: from, to: to) }

        it 'returns array of series' do
          expect(subject.series).to eq(expected_result)
        end
      end

      context 'period: month' do
        let(:from) { UTC.parse('01.01.2014 00:00:00') }
        let(:to) { UTC.parse('31.01.2014 23:59:59') }
        let(:period) { :month }
        let(:expected_result) { StatsHelper.generate_series(interval: 1.month, value: 31 * 24, from: from, to: to) }

        it 'returns array of series' do
          expect(subject.series).to eq(expected_result)
        end
      end

      pending 'quarter'
      pending 'year'
    end

    describe '#series_values' do
    end
  end
  
  # describe '#series_quantities' do
  #   let(:result) { subject.send(:series_quantities) }

  #   context 'by days' do
      # subject { Stats::Forecast.new(item, period: :day, from: Time.parse('01-01-2014 00:00:00 UTC'), to: Time.parse('05-01-2014 00:00:00 UTC')) }
  #     before { StatsHelper.generate_values(5, item: item) }
  #     it 'generates list of dates for time series' do
  #       expect(result).to eq({ '2014-01-01' => 1.0, '2014-01-02' => 2.0, '2014-01-03' => 3.0, '2014-01-04' => 4.0, '2014-01-05' => 5.0 })
  #     end
  #   end

  #   context 'by months' do
  #     subject { Stats::Forecast.new(item, period: :month, from: Time.parse('01-01-2014 00:00:00 UTC'), to: Time.parse('01-03-2014 00:00:00 UTC')) }
  #     before { StatsHelper.generate_values(5, item: item) }
  #     it 'generates list of dates for time series' do
  #       expect(result).to eq({ '2014-01' => 15.0 })
  #     end
  #   end
  # end

  # describe '#series_dates' do
  #   let(:result) { subject.send(:series_dates) }
  #   let(:mapped_result) do
  #     result.map { |k| k[:timestamp] }
  #   end

  #   context 'by days' do
  #     subject { Stats::Forecast.new(item, period: :day, from: Time.parse('01-01-2014 00:00:00 UTC'), to: Time.parse('05-01-2014 00:00:00 UTC')) }
  #     it 'generates list of dates for time series' do
  #       expect(mapped_result).to eq ['2014-01-01', '2014-01-02', '2014-01-03', '2014-01-04', '2014-01-05']
  #     end
  #   end

  #   context 'by months' do
  #     subject { Stats::Forecast.new(item, period: :month, from: Time.parse('01-01-2014 00:00:00 UTC'), to: Time.parse('01-03-2014 00:00:00 UTC')) }
  #     it 'generates list of dates for time series' do
  #       expect(mapped_result).to eq ['2014-01', '2014-02', '2014-03']
  #     end
  #   end
  # end

  # describe '#series' do
  #   let(:result) { subject.send(:series) }

  #   context 'by days' do
  #     subject { Stats::Forecast.new(item, period: :day, from: Time.parse('01-01-2014 00:00:00 UTC'), to: Time.parse('05-01-2014 00:00:00 UTC')) }
  #     before { StatsHelper.generate_values(5, item: item) }
  #     it 'generates list of dates for time series' do
  #       expect(result).to eq [1.0, 2.0, 3.0, 4.0, 5.0]
  #     end
  #   end

  #   context 'by months' do
  #     subject { Stats::Forecast.new(item, period: :month, from: Time.parse('01-01-2014 00:00:00 UTC'), to: Time.parse('01-03-2014 00:00:00 UTC')) }
  #     before { StatsHelper.generate_values(5, item: item) }
  #     it 'generates list of dates for time series' do
  #       expect(result).to eq [15.0, 0.0, 0.0]
  #     end
  #   end
  # end

  describe '#calculate' do
    subject { Stats::Forecast.new(item, period: period, depth: depth, from: from, to: to) }
    let(:result) { subject.send(:calculate) }
    let(:interval) { 1.hour }

    before do
      StatsHelper.generate_values(item: item, from: from, to: to, interval: interval, value: 1)
    end

    context 'by hours' do
      let(:period) { :hour }
      let(:depth) { 12 }
      let(:from) { UTC.parse('01.01.2014 00:00:00') }
      let(:to) { UTC.parse('05.01.2014 23:59:59') }

      it 'generates list of predictions' do
        puts result.inspect
        expect(result.to_a.count).to eq(12)
        # @todo
        # {{:from=>2014-01-06 00:00:00 UTC, :to=>2014-01-06 00:59:59 UTC}=>1.0, {:from=>2014-01-06 01:00:00 UTC, :to=>2014-01-06 01:59:59 UTC}=>1.0, {:from=>2014-01-06 02:00:00 UTC, :to=>2014-01-06 02:59:59 UTC}=>1.0, {:from=>2014-01-06 03:00:00 UTC, :to=>2014-01-06 03:59:59 UTC}=>1.0, {:from=>2014-01-06 04:00:00 UTC, :to=>2014-01-06 04:59:59 UTC}=>1.0, {:from=>2014-01-06 05:00:00 UTC, :to=>2014-01-06 05:59:59 UTC}=>1.0, {:from=>2014-01-06 06:00:00 UTC, :to=>2014-01-06 06:59:59 UTC}=>1.0, {:from=>2014-01-06 07:00:00 UTC, :to=>2014-01-06 07:59:59 UTC}=>1.0, {:from=>2014-01-06 08:00:00 UTC, :to=>2014-01-06 08:59:59 UTC}=>1.0, {:from=>2014-01-06 09:00:00 UTC, :to=>2014-01-06 09:59:59 UTC}=>1.0, {:from=>2014-01-06 10:00:00 UTC, :to=>2014-01-06 10:59:59 UTC}=>1.0, {:from=>2014-01-06 11:00:00 UTC, :to=>2014-01-06 11:59:59 UTC}=>1.0}
      end
    end

    context 'by days' do
      let(:period) { :day }
      let(:depth) { 3 }
      let(:from) { UTC.parse('01.01.2014 00:00:00') }
      let(:to) { UTC.parse('05.01.2014 23:59:59') }

      it 'generates list of predictions' do
        puts result.inspect
        expect(result.to_a.count).to eq(3)
        # @todo
        # {{:from=>2014-01-06 00:00:00 UTC, :to=>2014-01-06 23:59:59 UTC}=>24.0, {:from=>2014-01-07 00:00:00 UTC, :to=>2014-01-07 23:59:59 UTC}=>24.0, {:from=>2014-01-08 00:00:00 UTC, :to=>2014-01-08 23:59:59 UTC}=>24.0}
      end
    end

    context 'by weeks' do
      let(:period) { :week }
      let(:depth) { 1 }
      let(:from) { UTC.parse('01.01.2014 00:00:00') }
      let(:to) { UTC.parse('31.01.2014 23:59:59') }

      it 'generates list of predictions' do
        puts result.inspect
        expect(result.to_a.count).to eq(1)
        # @todo
        # {{:from=>2014-02-01 00:00:00 UTC, :to=>2014-02-07 23:59:59 UTC}=>148.79999999999995}
      end
    end

    context 'by months' do
      let(:period) { :month }
      let(:depth) { 3 }
      let(:from) { UTC.parse('01.01.2014 00:00:00') }
      let(:to) { UTC.parse('01.12.2014 00:00:00') }
      let(:interval) { 1.day }

      it 'generates list of predictions' do
        puts result.inspect
        expect(result.to_a.count).to eq(3)
        # @todo
        # {{:from=>2015-01-01 00:00:00 UTC, :to=>2015-01-31 23:59:59 UTC}=>27.91666666666667, {:from=>2015-02-01 00:00:00 UTC, :to=>2015-02-28 23:59:59 UTC}=>27.91666666666667, {:from=>2015-03-01 00:00:00 UTC, :to=>2015-03-31 23:59:59 UTC}=>27.91666666666667}
      end
    end

    context 'by quarters' do
      let(:period) { :quarter }
      let(:depth) { 3 }
      let(:from) { UTC.parse('01.01.2014 00:00:00') }
      let(:to) { UTC.parse('01.12.2014 00:00:00') }
      let(:interval) { 1.day }

      it 'generates list of predictions' do
        puts result.inspect
        expect(result.to_a.count).to eq(3)
        # @todo
        # {{:from=>2015-03-01 00:00:00 UTC, :to=>2015-05-31 23:59:59 UTC}=>83.75000000000001, {:from=>2015-06-01 00:00:00 UTC, :to=>2015-08-31 23:59:59 UTC}=>83.75000000000001, {:from=>2015-09-01 00:00:00 UTC, :to=>2015-11-30 23:59:59 UTC}=>83.75000000000001}
      end
    end

    context 'by years' do
      let(:period) { :year }
      let(:depth) { 2 }
      let(:from) { UTC.parse('01.01.2000 00:00:00') }
      let(:to) { UTC.parse('01.12.2014 00:00:00') }
      let(:interval) { 1.month }

      it 'generates list of predictions' do
        puts result.inspect
        expect(result.to_a.count).to eq(2)
        # @todo
        # {{:from=>2015-01-01 00:00:00 UTC, :to=>2015-12-31 23:59:59 UTC}=>1.0, {:from=>2016-01-01 00:00:00 UTC, :to=>2016-12-31 23:59:59 UTC}=>1.0}
      end
    end

  end
end
