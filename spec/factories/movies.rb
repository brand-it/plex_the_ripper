# frozen_string_literal: true

FactoryBot.define do
  factory :movie, aliases: [:video] do
    title { Faker::Book.title }
    original_title { Faker::Book.title }
    disk
  end
end
