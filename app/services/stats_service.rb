# frozen_string_literal: true

class StatsService < ApplicationService
  Z_SCORE_THRESHOLD = 5
  Info = Data.define(
    :median,
    :weighted_average,
    :median_difference,
    :weighted_average_difference,
    :interquartile_range,
    :z_score,
    :differences
  )

  param :list, Types::Array.of(Types::Coercible::Integer)

  def call
    Info.new(
      median,
      weighted_average,
      median_difference,
      weighted_average_difference,
      interquartile_range,
      z_score,
      differences
    )
  end

  private

  def median
    return if list.empty?

    @median ||= calc_median(list)
  end

  def weighted_average
    return if median.nil?

    calc_weight_average(list, median)
  end

  def median_difference
    return if differences.empty?

    @median_difference ||= calc_median(differences)
  end

  def differences
    @differences ||= list.uniq.permutation(2).map { _1.inject(:-).abs }.sort
  end

  def weighted_average_difference
    return if differences.empty?

    calc_weight_average(differences, median_difference)
  end

  def interquartile_range
    return if differences.empty?

    q1 = differences[(differences.size * 0.25).floor]
    q3 = differences[(differences.size * 0.50).floor]
    iqr = q3 - q1

    upper_bound = q3 + (1.5 * iqr)

    filtered_differences = differences.select { _1 <= upper_bound }

    filtered_differences.max
  end

  def z_score
    return if differences.empty?

    mean = differences.sum.to_f / differences.size

    # Calculate standard deviation
    variance = differences.map { |x| (x - mean)**2 }.sum / differences.size
    stdev = Math.sqrt(variance)

    differences.select do |x|
      z_score = (x - mean) / stdev
      z_score.abs < Z_SCORE_THRESHOLD
    end.max
  end

  def calc_weight_average(array, median)
    weights = array.map do |item|
      1.0 / (1.0 + (item - median).abs)
    end

    weighted_sum = array.each_with_index.reduce(0) do |sum, (item, index)|
      sum + (item * weights[index])
    end

    weighted_sum / weights.sum
  end

  def calc_median(array)
    if array.size.odd?
      array[array.size / 2]
    else
      mid1 = array[(array.size / 2) - 1]
      mid2 = array[array.size / 2]
      (mid1 + mid2) / 2.0
    end
  end
end
