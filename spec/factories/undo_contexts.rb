FactoryGirl.define do
  factory :undo_context, class: 'Undoable::UndoContext' do
    handle 'handle'
    context {}
  end
end
