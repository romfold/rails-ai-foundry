# frozen_string_literal: true

class IndexTransport
  attr_accessor :reject_validation
  attr_reader :active

  def initialize
    @candidates = {}
    @active = []
  end

  def create_candidate
    id = @candidates.size + 1
    @candidates[id] = []
    id
  end

  def replace(candidate, rows)
    @candidates[candidate] = rows
  end

  def valid?(candidate, rows)
    !reject_validation && @candidates.fetch(candidate) == rows
  end

  def activate(candidate)
    @active = @candidates.fetch(candidate)
  end
end
