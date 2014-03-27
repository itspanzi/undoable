module Undoable
  module UndoHelper
    def undo_required?
      request.env['HTTP_UNDO_REQUIRED']
    end
  end
end