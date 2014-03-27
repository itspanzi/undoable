module Undoable
  class UndoController < ApplicationController
    include ParamHandler

    UNDOABLE_RESOURCES = {}

    def perform_undo
      undo_params = context = UndoContext.where(handle: params.require(:handle)).first
      resource = resource_for(undo_params[:resource])
      if resource
        handle_undo(resource, undo_params)
      else
        render json: {errors: error_message("Resource '#{undo_params[:resource]}' is unknown.")}, status: :unprocessable_entity
      end
    end

    private

    def handle_undo(resource, undo_params)
      undo_params[:attributes] = massage_attributes(undo_params[:attributes]) unless undo_params[:attributes].is_a?(Array)
      result = resource.undo(undo_params)
      if result == true
        render nothing: true, status: :no_content
      else
        render json: {errors: error_message(result)}, status: :unprocessable_entity
      end
    end

    def resource_for(resource)

      UNDOABLE_RESOURCES[resource]
    end

    def error_message(reason)
      "Your last action could not be undone. Reason - #{reason}"
    end
  end
end
