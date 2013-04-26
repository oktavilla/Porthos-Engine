require_relative '../../test_helper'
require_relative '../../../lib/caching_shell'
require 'minitest/autorun'

describe CachingShell::Shell do
  before :each do
    CachingShell.object_cache.clear
    DatabaseCleaner.clean
  end

  describe "with_handle" do
    describe "with a new handle" do
      subject do
        CachingShell::Shell.with_handle 'new-handle'
      end

      it "creates a new shell" do
        CachingShell::Shell.expects(:create).with handle: 'new-handle'
        subject
      end

      it "stores the shell in memory" do
        handle = subject.handle
        CachingShell.object_cache.get(handle).must_equal subject
      end
    end

    describe "with an existing handle" do
      before :each do
        @shell = CachingShell::Shell.create handle: 'existing-handle'
      end

      subject do
        CachingShell::Shell.with_handle 'existing-handle'
      end

      it "finds the shell from the database" do
        subject.must_equal @shell
      end

      it "stores the shell in memory" do
        handle = subject.handle
        CachingShell.object_cache.get(handle).must_equal @shell
      end
    end

    describe "when already loaded" do
      it "fetches the shell from memory" do
        shell = CachingShell::Shell.new
        CachingShell.object_cache.set 'stored', shell
        CachingShell::Shell.with_handle('stored').must_equal shell
      end
    end
  end
end

