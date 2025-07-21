class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    if Rails.env.development?
      @posts = Post.all.order(created_at: :desc)
    else
      @posts = Post.all.published.order(created_at: :desc)
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /posts/1 or /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, status: :see_other, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find_by(slug: params[:id] || params[:slug])
      
      # If we still can't find the post, try to find it by ID as a fallback
      @post ||= Post.find_by(id: params[:id] || params[:slug]) if (params[:id] || params[:slug]).to_i > 0
      
      # If we still can't find the post, raise a 404
      raise ActiveRecord::RecordNotFound, "Couldn't find Post with 'id'=#{params[:id] || params[:slug]}" if @post.nil?
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.expect(post: [ :title, :slug, :status, :content, :tldr, :image_path ])
    end
end
