class WundereelNotifications < ApplicationMailer
  default from: 'wunderloader@wundereel.com'

  def loaded(job)
    @job = job
    mail(to: ENV.fetch('MAILER_ORDER_RECIPIENT'), subject: 'Wundereel Created')
  end

  def receipt(job)
    @job = job
    mail(to: @job.user.email, subject: "Your Wundereel Details ##{@job.id}")
  end

  def non_dropbox_email(interested_person)
    @interested_person = interested_person
    mail(to: ENV.fetch('EMAIL_SIGNUP_RECIPIENT'), subject: 'Non-Dropbox Customer')
  end

end
