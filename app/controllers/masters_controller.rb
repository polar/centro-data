require "open-uri"

class MastersController < ApplicationController

  # GET /masters
  def index
    @masters = Master.all
  end

  # GET /masters/1
  def show
    set_master
  end

  # GET /masters/new
  def new
    @master = Master.new
  end

  # GET /masters/1/edit
  def edit
    set_master
  end

  # POST /masters
  def create
    @master = Master.new(master_params)

    if @master.save
      redirect_to @master, notice: 'Master was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /masters/1
  def update
    set_master
    if @master.update(master_params)
      redirect_to @master, notice: 'Master was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def refresh
    url = "https://busme-apis.herokuapp.com/apis/d1/discover"
    Master.destroy_all
    resp = Hash.from_xml open(url)
    for m in resp["masters"]["master"] do
      m["bounds"] = m["bounds"].split(",").map {|x| x.to_f}
      master = Master.new()
      master.from_hash(m)
      master.save
    end
    redirect_to masters_path
  end

  # DELETE /masters/1
  def destroy
    set_master
    @master.destroy
    redirect_to masters_url, notice: 'Master was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_master
      @master = Master.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def master_params
      params[:master]
    end
end
