class Api::V1::UserFilesController < ApplicationController
  before_action :authenticate_user!
  def index
    dropbox_auth = current_user.auth_for_provider('dropbox_oauth2')

    user_status = DropboxCache.instance.status_for(dropbox_auth.uid)
    render :json => {
      currentTime: DateTime.now.to_i,
      fileCount: user_status[:count],
      fileSize: ActionController::Base.helpers.number_to_human_size(user_status[:size]),
      settled: user_status[:settled],
    }
  end
end
