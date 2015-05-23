require('dropbox_sdk')

# Dropbox utility methods
module DropboxUtility
  module_function

  def length_for_file(token, path)
    client(token)
      .metadata(path, 1, false, nil, nil, false, true)['video_info']['duration']
  end

  def job_description(job) # rubocop:disable Metrics/MethodLength
    <<-DESC.gsub(/ {6}/, '')
      Creation Date: #{DateTime.now.in_time_zone.to_date}
      Customer Name: #{job.user.name}
      Email: #{job.user.email}
      Cust UID: #{job.user.id}
      Reel UID: #{job.id}
      Sum of length of raw video files in reel folder:
      Title: #{job.title}
      Music Genre: #{job.music}
      Job Folder: #{job_folder(job)}
      Notes to Editor:
      #{job.notes}
      Names in Reel:
      #{job.names_in_reel}
      Share Friends:
      #{job.share_emails}
    DESC
  end

  def job_folder(job)
    "/wundereel/#{job.user.id} #{job.user.name}/#{job.id} #{job.title}/"
  end

  def client_from_token(token)
    DropboxClient.new token
  end

  def uploader_client
    DropboxClient.new ENV.fetch 'DROPBOX_UPLOADER_TOKEN'
  end

  def sync_job_files(job)
    client = uploader_client

    client.put_file job_folder(job) + "SPEC - Reel #{job.id}.txt", job_description(job)

    job.files.each do |file|
      client.add_copy_ref job_folder(job) + file.original_path.split('/')[-1], file.copy_ref
    end
  end

  def copy_ref_from_path(token, path)
    client = DropboxClient.new token
    client.create_copy_ref(path)['copy_ref']
  end

  def videos_for_user(user)
    all_video(user.dropbox_token)
  end

  def all_video(token)
    all_delta(token).select do |_name, meta|
      !meta['is_dir'] && meta['mime_type'] =~ %r{^video/}
    end
  end

  def all_delta(token) # rubocop:disable Metrics/MethodLength
    session = DropboxOAuth2Session.new token

    scanned = 0
    files = {}
    cursor = nil

    has_more = true
    while has_more
      result = Dropbox.parse_response(
        session.do_post(
          '/delta',
          'include_media_info': true,
          cursor: cursor
        )
      )
      cursor, has_more = result.values_at 'cursor', 'has_more'
      scanned += result['entries'].length
      $stderr.puts "SCanned #{scanned} files"

      result['entries'].each do |(file, meta)|
        files[file] = meta
      end
    end
    files
  end
end
