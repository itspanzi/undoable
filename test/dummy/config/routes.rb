Rails.application.routes.draw do

  mount Undoable::Engine => "/undoable"
end
