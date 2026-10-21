# frozen_string_literal: true

class VerificationPageController < ActionController::Base
  def show
    raise NoMethodError, 'missing_application_method' if ENV['FOUNDRY_FIXTURE_FAULT'] == 'caller'

    action = ENV['FOUNDRY_FIXTURE_FAULT'] == 'browser' ? '' : "document.getElementById('status').textContent = 'Saved'"
    render html: <<~HTML.html_safe
      <!doctype html><html><body>
        <label for="draft">Draft</label><input id="draft">
        <button onclick="#{action}">Save</button><p id="status">Editing</p>
      </body></html>
    HTML
  end
end

VerificationPage = VerificationPageController.action(:show)
