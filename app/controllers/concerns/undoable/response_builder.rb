module Undoable
  module ResponseBuilder
    def update_response(resource, old_attrs)
      resource_json = resource.as_json(root: true)
      if undo_required?
        undo_context = resource.build_update_undo_context(old_attrs)
        resource_json.merge!(undo_context: undo_context, undo_required: true) if undo_context
      end
      resource_json
    end

    def bulk_update_response(resource_class, resources_to_old_attrs)
      resource_json = {"voicemails" => resources_to_old_attrs.keys}.as_json
      if undo_required?
        undo_context = resource_class.bulk_update_undo_context(resources_to_old_attrs)
        resource_json.merge!(undo_context: undo_context, undo_required: true) if undo_context
      end
      resource_json
    end

    def destroy_response(resource)
      resource_json = resource.as_json(root: true)
      if undo_required?
        undo_context = resource.build_delete_undo_context
        resource_json.merge!(undo_context: undo_context, undo_required: true) if undo_context
      end
      resource_json
    end

    def select_response(resource, old_attrs)
      resource_json = resource.as_json(root: true)
      if undo_required?
        undo_context = resource.build_select_undo_context(old_attrs)
        resource_json.merge!(undo_context: undo_context, undo_required: true) if undo_context
      end
      resource_json
    end
  end
end