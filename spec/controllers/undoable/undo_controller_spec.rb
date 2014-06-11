require 'spec_helper'

describe Undoable::UndoController do

  describe 'POST perform_undo' do

    context 'success' do

      it 'returns success if the undo succeeds' do
        attrs = { resource: 'Sample', attributes: {}, version: {} }
        FactoryGirl.create(:undo_context, handle: 'handle', context: attrs)
        expect_any_instance_of(Undoable::UndoContext).to receive(:undo).and_return(true)

        put :perform_undo, use_route: :undoable, handle: 'handle'

        expect(response.status).to eq(204)
      end
    end

    context 'failure' do

      it 'returns not-found if the undo context is not found' do
        put :perform_undo, use_route: :undoable, handle: 'not-found'
        expect(response).to be_not_found
        body = JSON.parse(response.body)
        expect(body['errors']['handle']).to eq(["Handle 'not-found' is not found."])
      end

      it 'returns unprocessable_entity if undoing fails' do
        attrs = { resource: 'Sample', attributes: {}, version: {} }
        FactoryGirl.create(:undo_context, handle: 'handle', context: attrs)
        expect_any_instance_of(Undoable::UndoContext).to receive(:undo).and_return('ActiveRecord issue')

        put :perform_undo, use_route: :undoable, handle: 'handle'

        expect(response.status).to eq(422)
        body = JSON.parse(response.body)
        expect(body['errors']['context']).to eq(["Failed to undo. Reason: ActiveRecord issue."])
      end

      context 'bad resource' do

        it 'returns unprocessable_entity if the resource to be undone is not found' do
          FactoryGirl.create(:undo_context, handle: 'handle', context: { resource: 'Resource' })
          put :perform_undo, use_route: :undoable, handle: 'handle'

          expect(response.status).to eq(422)
          body = JSON.parse(response.body)
          expect(body['errors']['resource']).to eq(["Resource 'Resource' is unknown or doesn't include the undoable module."])
        end

        it 'returns unprocessable_entity if the resource to be undone is not found' do
          FactoryGirl.create(:undo_context, handle: 'handle', context: { resource: 'NotUndoable' })
          put :perform_undo, use_route: :undoable, handle: 'handle'

          expect(response.status).to eq(422)
          body = JSON.parse(response.body)
          expect(body['errors']['resource']).to eq(["Resource 'NotUndoable' is unknown or doesn't include the undoable module."])
        end
      end
    end
  end
end
