module Porthos
  module MongoMapper

    class Instruction
      include ::MongoMapper::Document
      key :body, String
    end

    module Plugins
      module Instructable
        extend ActiveSupport::Concern

        module InstanceMethods

          def instruction_body
            @instruction_body ||= instruction.body if instruction
          end

          def instruction_body=(body)
            if instruction
              instruction.update_attributes(:body => body)
            else
              self.instruction = Porthos::MongoMapper::Instruction.create(:body => body)
            end
          end
        end

        included do
          key :instruction_id, ObjectId
          belongs_to :instruction, :class_name => 'Porthos::MongoMapper::Instruction'
        end
      end
    end

  end
end