# /jobs/*
class JobsController < ApplicationController
  before_action :set_job, only: [:show, :update, :destroy]
  before_action :authenticate_user!
  layout 'bare'

  # GET /jobs
  # GET /jobs.json
  def index
    @jobs = current_user.jobs.all
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_job
    @job = Job.find(params[:id])
  end


end
