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

    client.put_file(
      job_folder(job) + "SPEC - Reel #{job.id}.txt",
      job_description(job)
    )

    job.files.each do |file|
      client.add_copy_ref(
        job_folder(job) + file.original_path.split('/')[-1],
        file.copy_ref
      )
    end
  end

  def copy_ref_from_path(token, path)
    client = DropboxClient.new token
    client.create_copy_ref(path)['copy_ref']
  end

  def videos_for_user(user)
    all_video(user.dropbox_token)[:files]
  end

  def all_video(token)
    meta_response, files = all_delta(token).values_at :meta, :files
    files = files.select do |_name, meta|
      !meta['is_dir'] && meta['mime_type'] =~ %r{^video/}
    end
    {
      meta: meta_response,
      files: files
    }
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
    {
      meta: {
        cursor: cursor
      },
      files: files
    }
  end
end

def delta_for(token, cursor)
  session = DropboxOAuth2Session.new token
  Dropbox.parse_response(
    session.do_post(
      '/delta',
      'include_media_info': true,
      cursor: cursor
    )
  )
end

def update_user(dropbox_uid, token)
  tree = DBCache.tree(dropbox_uid)
  cursor = DBCache.cursor(dropbox_uid)

  has_more = true
  while has_more
    result = delta_for token, cursor

    tree = {} if result['reset']

    cursor = result['cursor']
    has_more = result['has_more']

    DBCache.store(
      dropbox_uid,
      update(result['entries'], tree),
      cursor
    )
  end
end

def update(entries, tree)
  entries.reduce(tree) do |new_tree, entry|
    apply_delta(new_tree, entry)
  end
end

def apply_delta(tree, entry)
  path, metadata = entry
  if metadata.nil?
    # Any entries that start with the deleted path get removed
    tree.reject { |k, _v| k.index(path) == 0 }
  elsif metadata['is_dir']
    # We don't actually care about caching folders. If we have a file at that
    # spot, it's been replaced by a folder. Drop it like it's cold.
    tree.reject { |k, _v| k == path }
  else
    hsh = {}
    hsh[path] = metadata

    tree.merge(hsh)
  end
end
