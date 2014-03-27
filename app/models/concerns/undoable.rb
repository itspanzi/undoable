module Undoable

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def bulk_update_undo_context(resources_to_old_attrs)
      undo_context = { attributes: []}
      resources_to_old_attrs.each do |r, old_attrs|
        r.build_bulk_update_undo_context(undo_context, old_attrs)
      end
      return nil if undo_context[:attributes].empty?
      undo_context.merge!({
                              resource: self.name,
                              method: 'bulk_put',
                              version: version_for(resources_to_old_attrs.keys)
                          })
    end

    def undo(undo_context)
      massage_attributes(undo_context[:attributes])
      return undo_update(undo_context[:attributes], undo_context[:version]) if 'put' == undo_context[:method]
      return undo_delete(undo_context[:attributes], undo_context[:version]) if 'delete' == undo_context[:method]
      return undo_bulk_update(undo_context[:attributes], undo_context[:version]) if 'bulk_put' == undo_context[:method]
    end

    def massage_attributes(attrs)
      attrs
    end

    private

    def undo_update(attributes, version)
      id = attributes.delete(:id)
      resource = self.find_by_id(id)
      if resource
        return Version.message if Version.compare_versions(version, resource)
        resource.update_attributes(attributes)
      else
        "#{self.name} with id '#{id}' not found."
      end
    rescue ActiveRecord::UnknownAttributeError => e
      e.message
    end

    def undo_delete(attributes, version)
      if self.find_by_id(attributes[:id])
        return "#{name} with this id already exists. Cannot undo the delete action."
      end
      resource = self.new(attributes) do |r|
        r.id = attributes[:id]
      end
      resource.save!
    rescue ActiveRecord::UnknownAttributeError => e
      e.message
    end

    def undo_bulk_update(attributes, version)
      message = ''
      self.transaction do
        attributes.each do |attrs|
          id = attrs.delete(:id)
          resource = self.find_by_id(id)
          if resource
            message = Version.message and raise ActiveRecord::Rollback if Version.compare_versions(version, resource)
            resource.update_attributes(attrs)
          else
            message = "#{self.name} with id '#{id}' not found."
            raise ActiveRecord::Rollback
          end
        end
      end
      message.empty? ? true : message
    rescue ActiveRecord::UnknownAttributeError => e
      e.message
    end

    def version_for(resources)
      resources.sort { |this, that| this.updated_at <=> that.updated_at }.last.undo_version_attributes
    end
  end

  def build_update_undo_context(old_attrs)
    return nil unless (changed_attrs(old_attrs) - undoable_attributes).empty?
    undo_response_json 'put', undo_context_attributes(old_attrs)
  end

  def build_bulk_update_undo_context(base_context, old_attrs)
    return unless (changed_attrs(old_attrs) - undoable_attributes).empty?
    base_context[:attributes] << undo_context_attributes(old_attrs)
    base_context
  end

  def build_delete_undo_context
    undo_response_json 'delete', self.as_json
  end

  def undoable_attributes
    self.class::UNDOABLE_ATTRIBUTES
  end

  def undo_version_attributes
    { last_modified_time: self.updated_at.to_s, id: self.id }
  end

  private

  def changed_attrs old_attrs
    old_attrs.map { |k,v| k if v != self.send(k) }.compact - ['updated_at']
  end

  def undo_context_attributes old_attrs
    changed_attrs = changed_attrs(old_attrs)
    undo_context_attributes = old_attrs.select { |k,v| changed_attrs.include?(k) }
    undo_context_attributes.merge!({'id' => self.id})
  end

  def undo_response_json method, attributes
    {
        resource: self.class.name,
        method: method,
        attributes: attributes,
        version: undo_version_attributes
    }
  end
end
