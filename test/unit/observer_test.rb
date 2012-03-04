require_relative '../test_helper'
class ObserverTest < ActiveSupport::TestCase
  context 'MongoMapper::Observer' do
    setup do
      @recorder = CallbackRecorder.instance
    end

    teardown do
      @recorder.reset
    end

    should "be an instance of an active model observer" do
      assert AnimalObserver.instance.kind_of?(ActiveModel::Observer)
    end

    context "when the observer has descendants" do
      setup do
        @observer = AnimalObserver.instance
      end

      should "observe descendent class" do
        animal = Animal.create name: 'Whale'
        assert_equal animal.name, @observer.last_after_create_record.try(:name)
        human = Biped.create name: 'Human'
        assert_equal human.name, @observer.last_after_create_record.try(:name)
      end
    end

    context "when the document is being created" do
      setup do
        @animal = Animal.create! name: 'Thing'
      end

      [ :before_create, :after_create,
        :before_save, :after_save ].each do |callback|

        should "observe #{callback}" do
          assert_equal 1, @recorder.call_count[callback], "should have called #{callback} once"
        end

        should "contain the model of the callback #{callback}" do
          assert_equal @animal, @recorder.last_record[callback]
        end
      end
    end

    context "when the document is being updated" do
      setup do
        @animal = Animal.create!
      end

      [ :before_update, :after_update,
        :before_save, :after_save ].each do |callback|

        should "observe #{callback}" do
          @recorder.reset
          @animal.update_attributes(name: 'Balbazur')
          assert_equal 1, @recorder.call_count[callback], "should have called #{callback} once"
        end

        should "contain the model of the #{callback}" do
          @recorder.reset
          @animal.update_attributes(name: 'Balbazur')
          assert_equal @animal, @recorder.last_record[callback]
        end
      end
    end

    context "when the document is being destroyed" do
      setup do
        @animal = Animal.create!
      end

      [:before_destroy, :after_destroy].each do |callback|

        should "observe #{callback}" do
          @recorder.reset
          @animal.destroy
          assert_equal 1, @recorder.call_count[callback], "should have called #{callback} once"
        end

        should "contain the model of the #{callback}" do
          @recorder.reset
          @animal.destroy
          assert_equal @animal, @recorder.last_record[callback]
        end
      end
    end

    context "when the document is being validated" do
      setup do
        @animal = Animal.new
      end

      [:before_validation, :after_validation].each do |callback|

        should "observe #{callback}" do
          @recorder.reset
          @animal.valid?
          assert_equal 1, @recorder.call_count[callback], "should have called #{callback} once"
        end

        should "contain the model of the #{callback}" do
          @recorder.reset
          @animal.valid?
          assert_equal @animal, @recorder.last_record[callback]
        end
      end
    end
  end
end
