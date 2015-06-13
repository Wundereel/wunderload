
module Jobs
  class CreateController < ApplicationController
    before_action :authenticate_user!
    before_action :set_job, except: [:new, :create_videos]
    def set_job
      @job = Job.find(params[:id])
    end

    def redirect_right_step
      case @job.status
      when 'empty'
        redirect_to new_jobs_create_url
      when 'videos_added'
        redirect_to add_information_jobs_create_url(@job)
      when 'information_added'
        redirect_to add_payment_jobs_create_url(@job)
      when 'complete'
        redirect_to @job
      end
    end

    layout 'bare'

    def new
      if _files_ready?
        @job = current_user.jobs.build
        @videos = DropboxCache.instance.get_tree current_user.auth_for_provider('dropbox_oauth2').uid
      else
        DeltaLoadDropboxJob.perform_later(
          current_user.auth_for_provider('dropbox_oauth2').uid,
          current_user.dropbox_token
        )
        render 'interstitial'
      end
    end

    def create_videos
      @job = current_user.jobs.create

      db_uid = current_user.auth_for_provider('dropbox_oauth2').uid

      total_size = 0
      job_file_sources.each do |original_path|
        file_size = DropboxCache.instance.file_size_from_path(db_uid, original_path.downcase)
        @job.files.build(
          original_path: original_path,
          copy_ref: DropboxUtility.copy_ref_from_path(
            current_user.dropbox_token, original_path
          ),
          file_size: file_size
        )
        total_size += file_size
      end
      @job.update file_size: total_size

      if @job.may_add_videos?
        @job.add_videos!
        redirect_to add_information_jobs_create_path(@job)
      else
        @videos = DropboxCache.instance.get_tree current_user.auth_for_provider('dropbox_oauth2').uid
        render :new
      end
    end

    def add_information
      redirect_right_step unless @job.videos_added?
    end

    def create_information
      return redirect_right_step unless @job.videos_added?

      @job.attributes = job_params

      if @job.may_add_information?
        @job.add_information!
        redirect_to add_payment_jobs_create_path(@job)
      else
        render :add_information
      end
    end

    def add_payment
      redirect_right_step unless @job.information_added?
    end

    def create_payment
      return redirect_right_step unless @job.information_added?
      purchase = @job.build_purchase(
        amount: 100_00,
        email: purchase_params[:stripeEmail],
        stripe_token: purchase_params[:stripeToken]
      )

      return render :add_payment unless purchase.save!

      purchase.process!

      if @job.may_add_payment?
        @job.add_payment!
        DropboxUtility.sync_job_files(@job)
        WundereelNotifications.loaded(@job).deliver_later
        PushToGoogleSheetJob.perform_later @job.id
        redirect_to @job, notice: 'Nice job!  Your work here is done.'
      else
        render :add_payment
      end
    end

    def _files_ready?
      # TODO: check freshness of files
      dropbox_auth = current_user.auth_for_provider('dropbox_oauth2')

      DropboxCache.instance.settled?(dropbox_auth.uid)
    end

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

    def purchase_params
      params.permit :stripeToken, :stripeEmail
    end


    def job_file_sources
      params.require(:job_files).require('original_path').select { |a| a != '0' }
    end


  end
end
