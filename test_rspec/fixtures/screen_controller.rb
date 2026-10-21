# frozen_string_literal: true

class ScreenController < ActionController::Base
  def show
    return head :not_found unless params[:identity] == 'reader' || ENV['FOUNDRY_FIXTURE_FAULT'] == 'authorization'

    action = ENV['FOUNDRY_FIXTURE_FAULT'] == 'browser' ? '' : "document.getElementById('status').textContent = 'Saved'"
    render html: <<~HTML.html_safe
      <!doctype html><html><body>
        <label for="draft">Draft</label><input id="draft">
        <button onclick="#{action}">Save</button><p id="status">Editing</p>
      </body></html>
    HTML
  end
end
