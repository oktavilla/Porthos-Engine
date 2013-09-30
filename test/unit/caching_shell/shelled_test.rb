require_relative '../../test_helper'
require_relative '../../../lib/caching_shell/shelled'
require_relative '../../support/models/shelled'

require 'minitest/autorun'


describe "Shelled" do

  it "defaults shell handle to the class name" do
    Shelled.shell_handle.must_equal "shelleds"
  end

  it "sets the shell handle" do
    NamedShelled.shell_handle.must_equal 'a-handle'
  end

  it "can access the shell" do
    Shelled.shell.must_equal CachingShell::Shell.with_handle 'shelleds'
  end

  it "uses the same shell from instances" do
    Shelled.new.shell.must_equal Shelled.shell
  end

  # Sanity check
  it "adds callbacks" do
    Shelled.after_save :lol
    Shelled.after_save_callbacks.must_include :lol
  end

  it "should run touch_shell after save" do
    Shelled.after_save_callbacks.must_include :touch_shell
  end

  it "should run touch_shell after destroy" do
    Shelled.after_destroy_callbacks.must_include :touch_shell
  end

  it "touches the shell" do
    shell = Shelled.shell
    shell.expects(:touch).once

    Shelled.new.send :touch_shell
  end
end
