module ArrayHelper
  def ranges_from_integers(integers)
    ranges = []
    max, min = nil, nil
    while integers.any?
      integer = integers.delete(integers.min).to_i

      if min.nil?
        min, max = integer, integer
      elsif (max + 1) == integer
        max = integer
      elsif min && max
        ranges.push(Range.new(min, max))
        max, min = nil, nil
      end
    end
    # means we are done and we need to push the last range
    ranges.push(Range.new(min, max)) if min && max

    ranges
  end
end
