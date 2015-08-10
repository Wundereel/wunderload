class DropboxThumbController < ApplicationController

  def get
    client = DropboxClient.new current_user.auth_for_provider('dropbox_oauth2').token

    $stderr.puts "Path is #{params}"
    response.headers['Expires'] = CGI.rfc1123_date(Time.now.utc + 10.minutes)
    send_data(
      client.thumbnail(params[:filepath], 'm'),
      type: 'image/jpeg',
      disposition: 'inline'
    )


  end
end
