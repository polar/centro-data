class Delayed::JobsController < ApplicationController
  def index
    @master = Master.find(params[:master_id])
    @jobs = Delayed::Job.all
  end

  def show
    @job = Delayed::Job.find(params[:id])
  end

  def new
    @job = Delayed::Job.new
  end

  def start
    @master = Master.find(params[:master_id])
    which = params[:kind]
    case which
      when "refresh"
        Delayed::Job.enqueue(RefreshJob.new(:refresh, 30, @master.api.id, "refresh"), :queue => "refresh")
      when "locate"
        Delayed::Job.enqueue(LocationJob.new(:locate, 05, @master.id), :queue => "locate")
      else
        flash[:error] = "Kind not selected"
    end
    redirect_to delayed_jobs_path(:master_id => @master)
  end

  def stop
    @master = Master.find(params[:master_id])
    which = params[:kind]
    case which
      when "refresh"
        Delayed::Job.where(:queue => "refresh").each {|x| x.destroy }
      when "locate"
        Delayed::Job.where(:queue => "locate").each {|x| x.destroy }
      else
        flash[:error] = "Kind not selected"
    end
    redirect_to delayed_jobs_path(:master_id => @master)
  end

  def create
    @job = Delayed::Job.new(params[:job])
    if @job.save
      redirect_to [:delayed, @job], :notice => "Successfully created job."
    else
      render :action => 'new'
    end
  end

  def edit
    @job = Delayed::Job.find(params[:id])
  end

  def update
    @job = Delayed::Job.find(params[:id])
    if @job.update_attributes(params[:job])
      redirect_to [:delayed, @job], :notice  => "Successfully updated job."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @job = Delayed::Job.find(params[:id])
    @job.destroy
    redirect_to delayed_jobs_url, :notice => "Successfully destroyed job."
  end
end
