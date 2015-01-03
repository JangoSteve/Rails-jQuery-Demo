class CommentsController < ApplicationController
  respond_to :js, :json, :html, :xml
  #respond_to :js, :only => [:create, :update, :destroy]
  # GET /comments
  # GET /comments.xml
  def index
    @comments = Comment.all
  end

  # GET /comments/1
  # GET /comments/1.xml
  def show
    @comment = Comment.find(params[:id])
  end

  # GET /comments/new
  # GET /comments/new.xml
  def new
    @comment = Comment.new
    #respond_with(@comment, :layout => false)
    respond_with do |format|
      format.html { render :layout => ! request.xhr? }
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
  end

  # POST /comments
  # POST /comments.xml
  def create
    @comment = Comment.create(comment_params)
    sleep 1 if params[:pause]
    respond_with(@comment)
    #redirect_to comments_path unless request.xhr?
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:id])
    respond_with do |format|
      format.html{ redirect_to @comment }
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @comment = Comment.destroy(params[:id])
  end

  private

  def comment_params
    if ENV["RAILS_VERSION"] != '3.2'
      params.require(:comment).permit(:subject, :body, :attachment)
    else
      params[:comment]
    end
  end

end
