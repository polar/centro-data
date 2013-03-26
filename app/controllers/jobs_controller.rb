class JobsController < ApplicationController
  def index
    @jobs = Delayed::Job.all
  end
  def start
    Delayed::Job.enqueue CollectJob.new("collect", 10, [43,44,45,144,244,344,443,243,643]), :queue => "collect"
    redirect_to jobs_path
  end

  def stop
    puts "STOP JOBS"
    Delayed::Job.where(:queue => "collect").all.each {|x| x.destroy}
    redirect_to jobs_path
  end
end
