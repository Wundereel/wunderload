class DeltaLoadDropboxJob < ActiveJob::Base
  queue_as :delta_load_dropbox

  rescue_from do
    retry_job wait: 10.seconds
  end

  def perform(dropbox_uid, token)

    logger.debug "Arguments are: #{dropbox_uid}, #{token}"

    DropboxCache.instance.update_user(dropbox_uid, token)
    
  end
end
