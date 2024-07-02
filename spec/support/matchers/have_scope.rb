# frozen_string_literal: true

# A quick and easy way to test scopes sql queries by checking only the sql output
#
# is_expected.to have_scope(:user, 1).where(id: 1)
module RSpec
  module Matchers
    class HaveScope
      attr_reader :scope_name, :args, :klass, :raised_exception

      def initialize(scope_name, *args)
        @scope_name = scope_name.to_sym
        @args = args
      end

      def description
        "have scope #{scope_name} that is valid"
      end

      def where(*args)
        @where = args
        self
      end

      def not(*args)
        @where_not = args
        self
      end

      def order(*args)
        @order = args
        self
      end

      def matches?(described_class)
        @klass = described_class.model_name.instance_variable_get(:@klass)

        has_scope? &&
          active_record_relation? &&
          valid_sql? &&
          sql_matcher.matches?(scope.to_sql)
      end

      def failure_message
        return "expected #{klass} to respond to #{scope_name}" unless has_scope?
        return "expected #{scope.inspect} to be a ActiveRecord::Relation" unless active_record_relation?

        sql_matcher.failure_message
      end
      alias failure_message_when_negated failure_message

      private

      def sql_matcher
        @sql_matcher ||= RSpec::Matchers::BuiltIn::Eq.new(expected_relation.to_sql)
      end

      def expected_relation
        return @expected_relation if defined?(@expected_relation)

        @expected_relation = @klass

        if @where_not
          @expected_relation = @expected_relation.where.not(*@where_not)
        elsif @where
          @expected_relation = @expected_relation.where(*@where)
        end
        @expected_relation = @expected_relation.order(*@order) if @order
        @expected_relation
      end

      def valid_sql?
        scope.load
      rescue StandardError => e
        raise e, e.message, e.backtrace.reject { _1.include?(__FILE__) }
      end

      def has_scope?
        klass.respond_to?(scope_name)
      end

      def active_record_relation?
        scope.is_a?(ActiveRecord::Relation)
      end

      def scope
        klass.public_send(scope_name, *args)
      rescue StandardError => e
        raise e, e.message, e.backtrace.reject { _1.include?(__FILE__) }
      end
    end

    def have_scope(...)
      HaveScope.new(...)
    end
  end
end
