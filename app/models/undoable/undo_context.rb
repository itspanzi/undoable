class Undoable::UndoContext < ActiveRecord::Base
  serialize :context, JSON

end