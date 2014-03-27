Undoable::Engine.routes.draw do

  put '/undo', to: 'undo#perform_undo'
end
