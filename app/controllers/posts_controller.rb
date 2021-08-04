class PostsController < ApplicationController
  before_action :set_post, only: [:update, :destroy]

  def index
    @posts = current_user.posts
    render json: @posts, status: :ok
  end

  def show
    post = Post.find_by(id: params[:id])
    if post
      render json: post, status: :ok
    else
      render json: { error: I18n.t('posts.not_found') }, status: :not_found
    end
  end

  def create
    @post = current_user.posts.new(post_params)

    if @post.save
      render json: @post, status: :created, location: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      render json: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @post.destroy
      render json: { message: I18n.t('posts.deleted') }, status: :ok
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  private

  def set_post
    @post = current_user.posts.find_by(id: params[:id])
    unless @post
      render json: { error: I18n.t('posts.not_found') }, status: :not_found
    end
  end

  def post_params
    params.require(:post).permit(:content)
  end
end
