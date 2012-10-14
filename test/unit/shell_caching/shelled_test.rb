require_relative '../../test_helper'
require_relative '../../../lib/porthos/caching/shelled'
require_relative '../../support/models/shelled'
require 'mocha'

require 'minitest/autorun'


describe "Shelled" do
  it "can access the shell" do
    Shelled.shell.must_equal Porthos::Caching::Shell.with_handle 'shell-handle'
  end

  it "uses the same shell from instances" do
    Shelled.new.shell.must_equal Shelled.shell
  end

  it "should run touch_shell after save" do
    Shelled.after_save_callbacks.must_include :touch_shell
  end

  it "touches the shell" do
    shell = Shelled.shell
    shell.expects(:touch).once

    Shelled.new.send :touch_shell
  end
end
