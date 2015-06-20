class DropboxThumbController < ApplicationController

  def get
    client = DropboxClient.new current_user.auth_for_provider('dropbox_oauth2').token

    $stderr.puts "Path is #{params}"
    send_data(
      client.thumbnail(params[:filepath], 'm'),
      type: 'image/jpeg',
      disposition: 'inline'
    )


  end
end
