Undoable::Engine.routes.draw do

  namespace :undoable do
    put '/undo', to: 'undo#perform_undo'
  end
end
