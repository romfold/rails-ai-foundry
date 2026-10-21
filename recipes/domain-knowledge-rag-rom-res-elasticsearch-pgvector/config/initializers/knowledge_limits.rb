# frozen_string_literal: true

Rails.configuration.x.knowledge_limits = {
  document_page: 50, document_maximum: 100, retrieval_results: 5,
  retrieval_candidates: 100, rebuild_page: 250, bulk_bytes: 1_048_576
}.freeze
