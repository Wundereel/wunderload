class WundereelNotifications < ApplicationMailer
  default from: 'wunderloader@wundereel.com'

  def loaded(job)
    @job = job
    mail(to: ENV.fetch('MAILER_ORDER_RECIPIENT'), subject: 'Wundereel Created')
  end

end
