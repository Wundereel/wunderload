require 'logger'
require 'singleton'
# Update, store, and fetch from Redis for dropbox cache
class DropboxCache
  include Singleton

  def client
    @client ||= Redis::Namespace.new(:dropbox_cache)
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

  def get_tree(dropbox_uid)
    JSON.parse client.get("#{dropbox_uid}:files") || "{}"
  end

  def get_cursor(dropbox_uid)
    client.get("#{dropbox_uid}:files:cursor")
  end

  def settled?(dropbox_uid)
    res = client.get("#{dropbox_uid}:files:settled")
    if res.nil? || res == "0"
      false
    else
      true
    end
  end

  def update_user(dropbox_uid, token)
    tree = get_tree(dropbox_uid) || {}
    cursor = get_cursor(dropbox_uid)

    scanned = 0
    has_more = true
    $stderr.puts "cursor check is #{cursor.to_json}"
    client.set "#{dropbox_uid}:files:settled", 0
    while has_more
      result = delta_for token, cursor


      $stderr.puts result.except( 'entries' )

      tree = {} if result['reset']
      scanned += result['entries'].length

      $stderr.puts "Scanned #{scanned} entries"

      tree = update(tree, result['entries'])

      cursor = result['cursor']
      has_more = result['has_more']

      client.multi do |txn|
        txn.set "#{dropbox_uid}:files", tree.to_json
        txn.set "#{dropbox_uid}:files:cursor", cursor
        if has_more
          txn.set "#{dropbox_uid}:files:settled", 0
        else
          Rails.logger.debug "Setting settled with exp"
          txn.setex "#{dropbox_uid}:files:settled", 60, 1
        end
      end
    end
  end

  def update(tree, entries)
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
      if metadata['mime_type'].index('video') == 0
        hsh = {}
        hsh[path] = metadata

        tree.merge(hsh)
      else
        tree
      end
    end
  end
end
