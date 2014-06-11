class Undoable::UndoContext < ActiveRecord::Base
  serialize :context, JSON

  def resource
    context['resource']
  end
end