# frozen_string_literal: true

module ExecutableVerification
  private

  def verify_executable_guidance(pack_root)
    script = '.agents/skills/foundry-verify/scripts/verify.rb'
    arguments = ['--include-pack-tests', '--caller',
                 "#{pack_root}/billing/test/invoices_delivery_test.rb"]
    output = assert_command(RbConfig.ruby, script, *arguments)
    assert_includes output, 'Verified baseline:'
    assert_includes output, 'Verified caller:'
    view = "app/#{pack_root}/billing/app/views/billing/invoices/show.html.erb"
    original = File.binread(File.join(@root, view))
    write(view, '<%= @invoice.missing_application_method %>')
    output, error, status = command(RbConfig.ruby, script, *arguments)
    refute status.success?, output
    assert_match(/missing_application_method|500: Internal Server Error/, output)
    assert_includes error, 'baseline: command failed'
  ensure
    write(view, original) if original
  end

  def verify_installed_scripts(installed)
    Dir.children(File.join(installed, 'skills/foundry-verify/scripts')).sort.each do |file|
      relative = "skills/foundry-verify/scripts/#{file}"
      assert_equal File.binread(File.join(installed, relative)), File.binread(File.join(@app, '.agents', relative))
    end
  end
end
