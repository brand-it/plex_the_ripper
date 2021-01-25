# frozen_string_literal: true

class ApplicationQuery
  extend Dry::Initializer

  class << self
    def option_names
      @option_names ||= dry_initializer.options.map(&:target)
    end
  end

  def relation
    self.class.option_names.reduce(scope) { |scope, option| apply_filter(scope, option) }
  end

  def to_sql
    relation.to_sql.tr('\"', '')
  end

  private

  def apply_filter(scope, option)
    return scope unless respond_to?("filter_#{option}", true)
    return scope if send(option).nil? || send(option) == ''

    send("filter_#{option}", scope)
  end
end
