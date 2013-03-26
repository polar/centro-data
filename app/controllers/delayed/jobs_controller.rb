class Delayed::JobsController < ApplicationController
  def index
    @jobs = Delayed::Job.all
  end

  def show
    @job = Delayed::Job.find(params[:id])
  end

  def new
    @job = Delayed::Job.new
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
