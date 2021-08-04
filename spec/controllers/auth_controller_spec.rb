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

  describe '#sign_in' do
    let!(:user) { create :user, email: email }
    let(:params) { { email: email, password: password } }
    let(:response_data) { JSON.parse(response.body) }
    before { post :sign_in, params: params }
    describe 'when credentials are valid' do
      let(:email) { 'test@mail.com' }
      let(:password) { 'password' }
      it 'does successfully signed in' do
        expect(response.status).to eq(200)
      end

      it 'does have auth_token and expiry' do
        expect(response_data['auth_token']).to be_present
        expect(response_data['expiry']).to be_present
      end

      it 'does have the same email' do
        expect(response_data['email']).to eq(email)
      end
    end
    describe 'when credentials are invalid' do
      context 'if email is not correct' do
        let(:email) { 'test@mail.com' }
        let(:incorrect_email) { 'incorrect@mail.com' }
        let(:error) { 'invalid credentials' }
        let(:password) { 'password' }
        let(:params) { { email: incorrect_email, password: password } }
        it 'does have unauthorized status' do
          expect(response.status).to eq(401)
        end
        it 'does have error of invalid credentials' do
          expect(response_data['errors']).to eq(error)
        end
      end
      context 'if password is not correct' do
        let(:email) { 'test@mail.com' }
        let(:error) { 'invalid credentials' }
        let(:password) { 'password' }
        let(:incorrect_password) { 'incorrect_password' }
        let(:params) { { email: email, password: incorrect_password } }
        it 'does have unauthorized status' do
          expect(response.status).to eq(401)
        end
        it 'does have error of invalid credentials' do
          expect(response_data['errors']).to eq(error)
        end
      end
    end
  end

  describe '#sign_out' do
    let(:user) { create :user }
    let(:response_data) { JSON.parse(response.body) }
    let(:password) { 'password' }
    let(:message) { I18n.t('auth.signed_out') }
    let(:unauthorized_error) { 'you need to sign in before continue' }
    before do
      post :sign_in, params: { email: user.email, password: password }
      request.headers.merge!(Authorization: token)
      delete :sign_out
    end
    context 'if authorized user' do
      let(:token) { user.reload.auth_token }
      it 'does sign out successfully' do
        expect(response_data['message']).to eq(message)
      end
    end
    context 'if unauthorized user' do
      let(:token) { 'invalidtoken' }
      it 'does have error message' do
        expect(response_data['error']).to eq(unauthorized_error)
      end
    end
  end
end
