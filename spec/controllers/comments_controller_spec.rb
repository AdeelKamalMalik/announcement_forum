require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:response_data) { JSON.parse(response.body) }
  describe '#create' do
    let(:user_post) { create :post }
    let(:content) { 'testing content' }
    context 'if user is authorized' do
      let(:user) { create :user }
      before(:each) do
        sign_in(user)
        post :create, params: { comment: { content: content, post_id: user_post.id } }
      end
      it 'does have success response' do
        expect(response.status).to eq(201)
      end
      it 'does create comment for current user' do
        expect(response_data['id']).to be_present
        expect(response_data['user_id']).to eq(user.id)
      end
      it 'does have post in database' do
        expect(user_post.comments).to be_present
      end
      it 'does have same content' do
        expect(response_data['content']).to eq(content)
      end
    end
    context 'when user is not authorized' do
      before(:each) do
        post :create, params: { comment: { content: content, post_id: user_post.id } }
      end
      it 'does not allow to create the post' do
        expect(response_data['error']).to eq(I18n.t('auth.not_signed_in'))
      end
    end
  end
  describe '#update' do
    let(:user_post) { create :post }
    let(:user) { create :user }
    let(:comment) { create :comment, post: user_post, user: user }
    let(:content) { 'testing content' }
    context 'if user is authorized' do
      before(:each) do
        sign_in(user)
        put :update, params: { comment: { content: content, post_id: user_post.id }, id: comment.id }
      end
      it 'does have success response' do
        expect(response.status).to eq(200)
      end
      it 'does create comment for current user' do
        expect(response_data['id']).to be_present
        expect(response_data['user_id']).to eq(user.id)
      end
      it 'does have post in database' do
        expect(user_post.comments).to be_present
      end
      it 'does have same content' do
        expect(response_data['content']).to eq(content)
      end
    end
    context 'when user is not authorized' do
      before(:each) do
        put :update, params: { comment: { content: content, post_id: user_post.id }, id: comment.id }
      end
      it 'does not allow to create the post' do
        expect(response_data['error']).to eq(I18n.t('auth.not_signed_in'))
      end
    end
  end
  describe '#index' do
    describe 'when user is authorized' do
      let(:user) { create :user }
      let(:post_comments) { 2 }
      context 'if users fetching his all comments' do
        let!(:comment) { create_list :comment, post_comments, user: user }
        before(:each) { sign_in(user); get :index }
        it 'does have only current_user comments' do
          expect(response_data.size).to eq(user.comments.size)
          expect(response_data.map {|d| d['user_id']}.include?(user.id)).to be_truthy
        end
      end

      describe 'if user fetch post comments' do
        let!(:user_post) { create :post, :with_comments, total: post_comments }
        let!(:comment) { create :comment, user: user, post: user_post }
        context 'and if post is correct' do
          before(:each) { sign_in(user); get :index, params: { post_id: user_post.id } }
          it 'does have app comments' do
            expect(response_data.size).to eq(user_post.comments.count)
          end
        end
        context 'and if post id is incorrect' do
          before(:each) { sign_in(user); get :index, params: { post_id: 'Invalid' } }
          it 'does have error post not exists' do
            expect(response_data['message']).to eq(I18n.t('posts.not_found'))
          end
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
    describe 'when unauthorized user' do
      before(:each) { get :index }
      it 'does have authorization error' do
        expect(response_data['error']).to eq(I18n.t('auth.not_signed_in'))
      end
    end
  end

  describe '#show' do
    describe 'when user is authorized' do
      let(:user) { create :user }
      context 'if comment exists' do
        let(:comment) { create :comment }
        before { sign_in(user); get :show, params: {id: comment.id}}
        it 'does have comment' do
          expect(response_data['id']).to eq(comment.id)
          expect(response_data['content']).to eq(comment.content)
        end
      end
      context 'if comment not exists' do
        before { sign_in(user); get :show, params: { id: 'Invalid' }}
        it 'does have error' do
          expect(response_data['message']).to eq(I18n.t('comments.not_found'))
        end
      end
    end
  end

  describe '#destroy' do
    describe 'when user is authorized' do
      let(:user) { create :user }
      let!(:comment) { create :comment, user: user }
      context 'if current user deleting comment' do
        before { sign_in(user); delete :destroy, params: { id: comment.id }}
        it 'does delete successfully' do
          expect(response_data['message']).to eq(I18n.t('comments.deleted'))
        end
      end
      context 'if another user try to delete comment' do
        let(:other_user) { create :user }
        before { sign_in(other_user); delete :destroy, params: { id: comment.id }}
        it 'does delete successfully' do
          expect(response_data['error']).to eq(I18n.t('comments.not_found'))
        end
      end
      context 'if comment not exists' do
        before { sign_in(user); delete :destroy, params: { id: 'Invalid' }}
        it 'does have error' do
          expect(response_data['error']).to eq(I18n.t('comments.not_found'))
        end
      end
    end
  end

end
