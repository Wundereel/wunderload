class PushToGoogleSheetJob < ActiveJob::Base
  queue_as :push_to_google_sheet

  rescue_from do
    retry_job wait: 10.seconds
  end

  def perform(job_id)
    GoogleSheetUtility.push_to_sheet(Job.find(job_id))
  end
end
