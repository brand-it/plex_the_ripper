# frozen_string_literal: true

class VideosQuery < ApplicationQuery
  TypeAndId = Types::Hash.schema(type: Types::String, id: Types::Integer)

  param :scope, default: -> { Video.all }
  option :types_and_ids, Types::Array.of(TypeAndId).optional

  def filter_types_and_ids(relation)
    conditions = types_and_ids.map { |type_and_id| where_type_and_id(**type_and_id) }
    relation.where(conditions.join(' OR '))
  end

  private

  def where_type_and_id(type: nil, id: nil)
    "(#{arel_table[:type].eq(type).and(arel_table[:the_movie_db_id].eq(id)).to_sql})"
  end

  def arel_table
    @arel_table ||= Video.arel_table
  end
end
