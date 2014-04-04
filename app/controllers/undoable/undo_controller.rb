module Undoable
  class UndoController < ApplicationController
    include ParamHandler

    def perform_undo
      context = UndoContext.where(handle: params.require(:handle)).first
      render json: { errors: { handle: ["Handle '#{params[:handle]}' is not found."]}}, status: :not_found and return unless context
      undo_resource = context['resource']
      resource = resource_for(undo_resource)
      if resource
        handle_undo(resource, context)
      else
        render json: { errors: error_message("Resource '#{undo_resource}' is unknown.") }, status: :unprocessable_entity
      end
    end

    private

    def handle_undo(resource, undo_params)
      undo_params[:attributes] = massage_attributes(undo_params[:attributes])
      result = resource.undo(undo_params)
      if result == true
        render nothing: true, status: :no_content
      else
        render json: {errors: error_message(result)}, status: :unprocessable_entity
      end
    end

    def resource_for(resource)
      klazz = resource.classify.constantize
      klazz && klazz.included_modules.map(&:name).include?('Undoable')
    rescue NameError
      return false
    end

    def error_message(reason)
      "Your last action could not be undone. Reason - #{reason}"
    end
  end
end
