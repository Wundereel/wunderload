class Api::V1::UserFilesController < ApplicationController
  before_action :authenticate_user!
  def index
    dropbox_auth = current_user.auth_for_provider('dropbox_oauth2')

    if DropboxCache.instance.settled?(dropbox_auth.uid)
      head :ok
    else
      head :no_content
    end
  end
end
