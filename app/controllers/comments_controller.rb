class CommentsController < ApplicationController
  before_action :set_comment, only: [:update, :destroy]
  before_action :set_post, only: [:index, :show]

  def index
    @comments = current_user.comments
    @comments = @comments.of_post(@post.id) if @post
    render json: @comments, status: :ok
  end

  def show
    comment = @post.comments.find_by(id: params[:id]) if @post
    comment = Comment.find_by(id: params[:id]) unless @post
    if comment
      render json: comment, status: :ok
    else
      render json: { message: I18n.t('comments.not_found') }, status: :not_found
    end
  end

  def create
    @comment = current_user.comments.new(comment_params)

    if @comment.save
      render json: @comment, status: :created, location: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  def update
    if @comment.update(comment_params)
      render json: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @comment.destroy
      render json: { message: I18n.t('comments.deleted') }, status: :ok
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  private

  def set_comment
    @comment = current_user.comments.find_by(id: params[:id])
    unless @comment
      render json: { error: I18n.t('comments.not_found') }, status: :not_found
    end
  end

  def comment_params
    params.require(:comment).permit(:content, :post_id)
  end

  def set_post
    if params[:post_id]
      @post = Post.find_by(id: params[:post_id])
      unless @post
        render json: { message: I18n.t('posts.not_found') }
      end
    end
  end
end
