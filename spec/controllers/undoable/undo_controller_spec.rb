require 'spec_helper'

describe Undoable::UndoController do

  describe 'POST perform_undo' do

    context 'success' do
    end

    context 'failure' do

      it 'returns not-found if the undo context is not found' do
        put :perform_undo, use_route: :undoable, handle: 'not-found'
        expect(response).to be_not_found
        body = JSON.parse(response.body)
        expect(body['errors']['handle']).to eq(["Handle 'not-found' is not found."])
      end
    end
  end
end
