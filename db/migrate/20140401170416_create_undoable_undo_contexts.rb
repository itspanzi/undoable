class CreateUndoableUndoContexts < ActiveRecord::Migration
  def change
    create_table :undoable_undo_contexts do |t|
      t.string :handle
      t.string :context

      t.timestamps
    end
  end
end
