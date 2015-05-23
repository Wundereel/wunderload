# /jobs/*
class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  layout 'bare'

  # GET /jobs
  # GET /jobs.json
  def index
    @jobs = Job.all
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show
  end

  # GET /jobs/new
  def new
    @job = current_user.jobs.build
    @videos = DropboxUtility.videos_for_user current_user
  end

  # GET /jobs/1/edit
  def edit
  end

  # POST /jobs
  # POST /jobs.json
  def create
    @job = current_user.jobs.create job_params

    job_file_sources.each do |original_path|
      @job.files.build(
        original_path: original_path,
        copy_ref: DropboxUtility.copy_ref_from_path(
          current_user.dropbox_token, original_path
        )
      )
    end

    DropboxUtility.sync_job_files(@job)
    # TODO error handling pre sync

    respond_to do |format|
      if @job.save
        format.html do
          redirect_to @job, notice: 'Job was successfully created.'
        end
        format.json { render :show, status: :created, location: @job }
      else
        format.html { render :new }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jobs/1
  # PATCH/PUT /jobs/1.json
  def update
    respond_to do |format|
      if @job.update(job_params)
        format.html { redirect_to @job, notice: 'Job was successfully updated.' }
        format.json { render :show, status: :ok, location: @job }
      else
        format.html { render :edit }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    @job.destroy
    respond_to do |format|
      format.html { redirect_to jobs_url, notice: 'Job was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_job
    @job = Job.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list
  # through.
  def job_params
    params.require(:job).permit(
      :user_id,
      :title,
      :notes,
      :music,
      :names_in_reel,
      :share_emails,
      job_files_attributes: []
    )
  end

  def job_file_sources
    params.require(:job_files).require('original_path').select { |a| a != '0' }
  end
end