require 'google/api_client'
require 'google_drive'

# Dropbox utility methods
module GoogleSheetUtility
  module_function

  SCHEMA = [
    'Date Created',
    'Reel Name',
    'Dropbox - Full Name',
    'Dropbox - Email',
    'Credits',
    'Music',
    'Specific Requests',
    'Email Address(es)',
    'Raw Video Link',
    'Raw Size',
    'Amount Paid',
    'Payment Status'
  ]

  def session
    auth = Google::APIClient.new.authorization
    auth.client_id = "1079086378219-fkbmmpaptnjsal6ihsfdvftaqkgipcbk.apps.googleusercontent.com"
    auth.client_secret = "6JLdFGbf1WStVlom6L7nru6i"
    auth.scope = [
      "https://www.googleapis.com/auth/drive",
      "https://spreadsheets.google.com/feeds/"
    ]
    auth.refresh_token = ENV.fetch('DRIVE_REFRESH_TOKEN')
    auth.fetch_access_token!
    GoogleDrive.login_with_oauth(auth.access_token)
  end

  def job_to_row(job)
    [
      job.created_at,
      job.title,
      job.user.name,
      job.user.email,
      job.names_in_reel,
      job.music,
      job.notes,
      job.share_emails,
      'https://www.dropbox.com/work' + DropboxUtility.job_folder(job), #### THINGS
      job.file_size,
      '%.2f' % (job.purchase.amount/100),
      job.purchase.state
    ]
  end

  def check_schema!(ws)
    SCHEMA.each_with_index do |v, i|
      header = ws[1, i + 1]
      if header != v
        puts "#{v} doesn't match #{header}"
        throw 'Failure'
      else
        puts "#{v} matches"
      end
    end
  end

  def push_to_sheet(job)
    ws = session.spreadsheet_by_key(ENV.fetch('SPREADSHEET_KEY')).worksheets[ENV.fetch('SPREADSHEET_WS').to_i]

    check_schema!(ws)

    target_row = ws.num_rows + 1
    job_to_row(job).each_with_index do |v, i|
      ws[target_row, i + 1] = v
    end
    ws.save
  end
end
