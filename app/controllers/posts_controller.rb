class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :set_props, only: [:index]
  def home
  end

  # GET /posts
  # GET /posts.json
  def index

    @posts = Post.all.order("timestamp DESC").paginate(:page => params[:page], :per_page => 15)
    @posts = @posts.where(bedrooms: params["bedrooms"]) if params["bedrooms"].present? && params["bedrooms"].to_i > 0
    @posts = @posts.where(bathrooms: params["bathrooms"]) if params["bathrooms"].present? && params["bathrooms"].to_d > 0
    @posts = @posts.where(sqft: params["sqft"]) if params["sqft"].present? && params["sqft"].to_d > 0  
    @posts = @posts.where("price > ?", params["min_price"]) if params["min_price"].present? 
    @posts = @posts.where("price < ?", params["max_price"]) if params["max_price"].present?  
    @posts = @posts.where("sqft > ?", params["min_sqft"]) if params["min_sqft"].present? 
    @posts = @posts.where("sqft < ?", params["max_sqft"]) if params["max_sqft"].present?
    unless params[:is_hipster]
      @posts = @posts.where(neighborhood: params["neighborhood"]) if params["neighborhood"].present?
    else 
      @posts = @posts.where(is_hipster: "YES")
    end
    @posts = @posts.where(cats: params["cats"]) if params["cats"].present? 
    @posts = @posts.where(dogs: params["dogs"]) if params["dogs"].present? 
    @posts = @posts.where(dogs: params["w_d_in_unit"]) if params["w_d_in_unit"].present?
    
     
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @images = @post.images

    unless @post.neighborhood == nil
      @location  = Location.where(:name => @post.neighborhood).first;
      p @location.name
      @ppsf_avg = PricePerSqft.where(:location_id => @location.id).average(:value)
      p @ppsf_avg.to_s

      @this_ppsf = 0
      if (@post.price.to_i > 0) && (@post.sqft.to_i > 0)
        @this_ppsf = @post.price.to_d / @post.sqft.to_d
        p @this_ppsf.to_s
      end
    end 
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    def set_props
      @hipster_location_collection = ["USA-MIA-DOM", "USA-MIA-NOC", "USA-MIA-SOC", "USA-MIA-UPP", "USA-MIA-WYN"]
      @hipster_search_terms = ["ocean", "view", "beach"]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:heading, :body, :price, :neighborhood, :external_url, :timestamp)
    end
end
