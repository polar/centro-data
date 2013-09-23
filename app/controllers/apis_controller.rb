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

  def login
    set_api
    LocationJob.new().auth(@api, "token")
  end

  # PATCH/PUT /apis/1
  def update
    slug = params[:slug]
    master = Master.where(:slug => slug).first
    if master
      api = Api.where(:id => params[:id]).first
      if !api.nil?
        api.destroy
      end
      api = Api.new(:master => master)
      resp = Hash.from_xml open(master.api_url)
      api.from_hash(resp["API"])
      api.save
      redirect_to master_path(api.master), :notice => "API Updated"
    else
      redirect_to masters_path, :notice => "Master not found"
    end
  end

  def refresh
    api = Api.find(params[:id])
    RefreshJob.new(api.id).doit
    redirect_to routes_path(api)
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
