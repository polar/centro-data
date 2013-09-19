require "open-uri"

class ApisController < ApplicationController

  # GET /apis
  def index
    @apis = Api.all
  end

  # GET /apis/1
  def show
    set_api
  end

  # GET /apis/new
  def new
    @api = Api.new
  end

  # GET /apis/1/edit
  def edit
  end

  # POST /apis
  def create
    @api = Api.new(api_params)

    if @api.save
      redirect_to @api, notice: 'Api was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /apis/1
  def update
    if @api.update(api_params)
      redirect_to @api, notice: 'Api was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /apis/1
  def destroy
    @api.destroy
    redirect_to apis_url, notice: 'Api was successfully destroyed.'
  end


  def refresh
    slug = params[:slug]
    master = Master.where(:slug => slug).first
    resp = Hash.from_xml open(master.api)
    api = Api.new
    api.from_hash(resp["API"])
    api.save
    redirect_to api_path(api, :slug => slug)
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api
      @api = Api.find(params[:id])
    rescue
      @api = Api.new
    end

    # Only allow a trusted parameter "white list" through.
    def api_params
      params[:api]
    end
end
