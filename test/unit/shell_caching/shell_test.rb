require_relative '../../test_helper'
require_relative '../../../lib/porthos/caching/shell'
require 'mocha'
require 'minitest/autorun'

describe Porthos::Caching::Shell do
  before :each do
    Porthos::Caching.shell_cache.clear
    DatabaseCleaner.clean
  end

  describe "with_handle" do
    describe "with a new handle" do
      subject do
        Porthos::Caching::Shell.with_handle 'new-handle'
      end

      it "creates a new shell" do
        Porthos::Caching::Shell.expects(:create).with handle: 'new-handle'
        subject
      end

      it "stores the shell in memory" do
        handle = subject.handle
        Porthos::Caching.shell_cache.get(handle).must_equal subject
      end
    end

    describe "with an existing handle" do
      before :each do
        @shell = Porthos::Caching::Shell.create handle: 'existing-handle'
      end

      subject do
        Porthos::Caching::Shell.with_handle 'existing-handle'
      end

      it "finds the shell from the database" do
        subject.must_equal @shell
      end

      it "stores the shell in memory" do
        handle = subject.handle
        Porthos::Caching.shell_cache.get(handle).must_equal @shell
      end
    end

    describe "when already loaded" do
      it "fetches the shell from memory" do
        shell = Porthos::Caching::Shell.new
        Porthos::Caching.shell_cache.set 'stored', shell
        Porthos::Caching::Shell.with_handle('stored').must_equal shell
      end
    end
  end
end

