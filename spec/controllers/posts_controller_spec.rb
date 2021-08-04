require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:response_data) { JSON.parse(response.body) }
  describe '#create' do
    context 'when user is authorized' do
      let(:user) { create :user }
      let(:content) { 'testing content' }
      before(:each) do
        sign_in(user)
        post :create, params: { post: { content: content } }
      end
      it 'does have success response' do
        expect(response.status).to eq(201)
      end
      it 'does create Post for current user' do
        expect(response_data['id']).to be_present
        expect(response_data['user_id']).to eq(user.id)
      end
      it 'does have post in database' do
        expect(Post.last).to be_present
      end
      it 'does have same content' do
        expect(response_data['content']).to eq(content)
      end
    end
    context 'when user is not authorized' do
      let(:content) { 'testing content' }
      before(:each) do
        post :create, params: { post: { content: content } }
      end
      it 'does not allow to create the post' do
        expect(response_data['error']).to eq(I18n.t('auth.not_signed_in'))
      end
    end
  end

  describe '#update' do
    context 'when user is authorized' do
      let(:post) { create :post }
      let(:user) { post.user }
      let(:content) { 'testing content' }
      before(:each) do
        sign_in(user)
        put :update, params: { post: { content: content }, id: post.id }
      end
      it 'does have success response' do
        expect(response.status).to eq(200)
      end
      it 'does create Post for current user' do
        expect(response_data['id']).to be_present
        expect(response_data['user_id']).to eq(user.id)
      end
      it 'does have same content' do
        expect(response_data['content']).to eq(content)
      end
    end
    context 'when user is not authorized' do
      let(:content) { 'testing content' }
      before(:each) do
        post :create, params: { post: { content: content } }
      end
      it 'does not allow to create the post' do
        expect(response_data['error']).to eq(I18n.t('auth.not_signed_in'))
      end
    end
  end

  describe '#index' do
    describe 'when user is authorized' do
      context 'when users having posts' do
        before(:each) { sign_in(users.first); get :index }
        let(:total_posts) { 2 }
        let(:user_count) { 2 }
        let!(:users) { create_list :user, user_count, :with_posts, total: total_posts }
        it 'does have posts' do
          expect(response_data).not_to be_empty
        end
        it 'does have posts equal to total_posts' do
          expect(response_data.count).to eq(total_posts * user_count)
        end
        it 'does have other users posts' do
          expect(response_data.map { |d| d['user_id'] }.uniq.size).to eq(user_count)
        end
      end
      context 'when users do not have any post' do
        let(:user) { create :user }
        before(:each) { sign_in(user); get :index }
        it 'does have empty response' do
          expect(response.status).to eq(200)
          expect(response_data).to be_empty
        end
      end
    end
  end

  describe '#show' do
    let(:post) { create :post }
    context 'when user is authorized' do
      before { sign_in(post.user); get :show, params: { id: post.id } }
      it 'does have success status' do
        expect(response.status).to eq(200)
      end
      it 'does have same post' do
        expect(post.id).to eq(response_data['id'])
        expect(post.content).to eq(response_data['content'])
        expect(post.user_id).to eq(response_data['user_id'])
      end
    end
    context 'when user is not authorized' do
      before { get :show, params: { id: post.id } }
      it 'does have unauthorized user error' do
        expect(response_data['error']).to eq(I18n.t('auth.not_signed_in'))
      end
    end
  end

  describe '#destroy' do
    let(:post) { create :post }
    context 'when user is authorized' do
      before { sign_in(post.user); get :destroy, params: { id: post.id } }
      it 'does have success status' do
        expect(response.status).to eq(200)
      end
      it 'does have deleted message' do
        expect(response_data['message']).to eq(I18n.t('posts.deleted'))
      end
      it 'does not have post in database' do
        expect(Post.find_by(id: post.id)).not_to be_present
      end
    end
    context 'when user is not authorized' do
      before { get :show, params: { id: post.id } }
      it 'does have unauthorized user error' do
        expect(response_data['error']).to eq(I18n.t('auth.not_signed_in'))
      end
    end
  end
end
