# frozen_string_literal: true

require 'flow_nodes'

module ReviewFlow
  # Demonstration state survives repeats in this process only.
  class Effects
    attr_reader :entries

    def initialize
      @entries = {}
      @lock = Mutex.new
    end

    def put(key, value)
      @lock.synchronize do
        raise ArgumentError, 'Request key conflicts with prior content' if @entries.key?(key) && @entries[key] != value

        @entries[key] ||= value
      end
    end
  end

  class Classify < FlowNodes::Node
    def initialize(classifier)
      super(max_retries: 3, wait: 0)
      @classifier = classifier
    end

    def exec(params)
      @classifier.call(params.fetch(:text)).to_s
    end
  end

  class Review < FlowNodes::Node
    def initialize(output)
      super()
      @output = output
    end

    def exec(_params)
      @output[:status] = :needs_review
      nil
    end
  end

  class Deliver < FlowNodes::Node
    def initialize(effects, output, after_write)
      super(max_retries: 2, wait: 0)
      @effects = effects
      @output = output
      @after_write = after_write
    end

    def exec(params)
      value = @effects.put(params.fetch(:request_id), params.fetch(:text))
      @after_write.call
      @output.merge!(status: :delivered, value: value)
      nil
    end
  end

  def self.call(request_id:, text:, classifier:, effects:, after_write: -> {})
    validate_input(request_id, text)

    output = {}
    classify = Classify.new(classifier)
    (classify - :review) >> Review.new(output)
    (classify - :deliver) >> Deliver.new(effects, output, after_write)
    flow = FlowNodes::Flow.new(start: classify)
    # Upstream marshals params: keep callables and effect stores in constructor dependencies.
    flow.set_params(request_id: request_id, text: text)
    flow.run(nil)
    raise ArgumentError, 'Classifier returned an unsupported route' unless output[:status]

    output
  rescue Interrupt
    { status: :interrupted }
  end

  def self.validate_input(request_id, text)
    return unless request_id.to_s.empty? || text.to_s.empty?

    raise ArgumentError, 'Request id and text are required'
  end
  private_class_method :validate_input
end
