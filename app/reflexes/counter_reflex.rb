# frozen_string_literal: true

class CounterReflex < ApplicationReflex
  def increment
    current_count = element.dataset["count"].to_i
    new_count = current_count + 1

    morph "#counter", render(partial: "counter", locals: { count: new_count })
  end
end
