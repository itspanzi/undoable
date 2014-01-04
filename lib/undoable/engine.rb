module Undoable
  class Engine < ::Rails::Engine
    isolate_namespace Undoable
  end
end
