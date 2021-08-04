require 'rails_helper'

RSpec.describe AuthController, type: :controller do
  describe '#sign_up' do
    let(:response_data) { JSON.parse(response.body) }
    let(:params) { { email: email, password: password, password_confirmation: password_confirmation } }
    before(:each) { post :sign_up, params: params }
    context 'when params are correct' do
      let(:email) { 'testing@gmail.com' }
      let(:password) { 'password' }
      let(:password_confirmation) { password }
      it 'does have successful response' do
        expect(response.status).to eq(200)
      end

      it 'does create user' do
        expect(User.last.present?).to be_truthy
      end

      it 'does have same email' do
        expect(response_data['email']).to eq(email)
      end
    end
    describe 'when params are incorrect' do
      context 'if email is incorrect' do
        let(:email) { 'inCorrect' }
        let(:error) { 'is invalid' }
        let(:password) { 'password' }
        let(:password_confirmation) { password }
        it 'does have email error' do
          expect(response_data['errors']['email']).to be_present
        end
        it 'does have email error message' do
          expect(response_data['errors']['email'].first).to eq(error)
        end
      end
      context 'if password is empty' do
        let(:email) { 'test@mail.com' }
        let(:password) { '' }
        let(:error) { "can't be blank" }
        let(:password_confirmation) { password }

        it 'does have error of password' do
          expect(response_data['errors']['password']).to be_present
        end

        it 'does have error message of password' do
          expect(response_data['errors']['password'].first).to eq(error)
        end
      end
      context 'if confirmation password is not same' do
        let(:email) { 'test@mail.com' }
        let(:password) { 'password' }
        let(:error) { "doesn't match Password" }
        let(:password_confirmation) { '' }
        it 'does have error of password' do
          expect(response_data['errors']['password_confirmation']).to be_present
        end

        it 'does have error message of password' do
          expect(response_data['errors']['password_confirmation'].first).to eq(error)
        end
      end
    end

  end
end
