# frozen_string_literal: true

require_relative '../../../config/environment'
puts Knowledge::Rebuild.new.call
