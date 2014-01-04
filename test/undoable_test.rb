require 'test_helper'

class UndoableTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Undoable
  end
end
