module Undoable
  class UndoController < ApplicationController
    include ParamHandler

    def perform_undo
      context = UndoContext.where(handle: params.require(:handle)).first
      render json: { errors: { handle: ["Handle '#{params[:handle]}' is not found."] } }, status: :not_found and return unless context
      undo_resource = context.resource
      resource = resource_for(undo_resource)
      if resource
        handle_undo(context)
      else
        render json: { errors: { resource: ["Resource '#{undo_resource}' is unknown or doesn't include the undoable module."] } }, status: :unprocessable_entity
      end
    end

    private

    def handle_undo(context)
      result = context.undo
      if result == true
        render nothing: true, status: :no_content
      else
        render json: { errors: { context: ["Failed to undo. Reason: #{result}."]} }, status: :unprocessable_entity
      end
    end

    def resource_for(resource)
      klazz = resource.classify.constantize
      klazz && klazz.included_modules.map(&:name).include?('Undoable')
    rescue NameError
      return false
    end
  end
end
