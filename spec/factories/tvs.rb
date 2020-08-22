# frozen_string_literal: true

FactoryBot.define do
  factory :tv do
    name { Faker::Book.title }
    original_name { Faker::Book.title }
  end
end
