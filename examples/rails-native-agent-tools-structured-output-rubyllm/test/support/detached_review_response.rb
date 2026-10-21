# frozen_string_literal: true

# Chrome 153 misclassifies detached DOM nodes during frame replacement. Convert
# only its exact inspector error so Capybara can refind the element normally.
module DetachedReviewResponse
  private

  def assert_ok
    super
  rescue Selenium::WebDriver::Error::UnknownError => e
    raise unless e.message.include?('Node with given id does not belong to the document')

    raise Selenium::WebDriver::Error::StaleElementReferenceError, 'Status frame was replaced'
  end
end
