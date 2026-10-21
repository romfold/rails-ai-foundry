# frozen_string_literal: true

require 'test_helper'

class InvoicesTest < ActionDispatch::IntegrationTest
  def setup
    Billing::Invoice.delete_all
    @paid = Billing::Invoice.create!(reference: 'PAID', amount_cents: 1250, status: 'paid')
    @open = Billing::Invoice.create!(reference: 'OPEN', amount_cents: 3400, status: 'open')
  end

  def test_legacy_and_public_reports_preserve_the_paid_total
    %w[/legacy_report /report].each do |path|
      get path
      assert_response :success
      assert_equal({ 'paid_cents' => 1250 }, response.parsed_body)
    end
    assert_equal 1250, Billing::Invoices.total_paid_cents
  end

  def test_payment_changes_persist_once_and_missing_records_fail
    2.times do
      post pay_invoice_path(@open)
      assert_response :see_other
    end
    assert_equal 'paid', @open.reload.status
    assert_equal 4650, Billing::Invoices.total_paid_cents
    assert_equal 2, Billing::Invoice.count
    assert_equal :not_found, Billing::MarkPaid.new.call(-1).failure
    post pay_invoice_path(-1)
    assert_response :not_found
  end

  def test_view_and_database_constraints
    get root_path
    assert_response :success
    assert_select 'td', text: 'OPEN'
    assert_select 'button', text: 'Mark paid'
    assert_raises(ActiveRecord::RecordInvalid) { @open.update!(amount_cents: -1) }
    assert_raises(ActiveRecord::StatementInvalid) do
      Billing::Invoice.where(id: @open.id).update_all(amount_cents: -1)
    end
    assert_equal 3400, @open.reload.amount_cents
  end
end
