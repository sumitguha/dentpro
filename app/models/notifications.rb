class Notifications < ActionMailer::Base


  def quote(quote = nil, customer = nil, price = nil, sent_at = Time.now )
    subject    'DentPro Appointment Request'
    recipients DENTPRO_EMAIL_RECIPIENTS
    from       DENTPRO_EMAIL_FROM
    sent_on    sent_at

    body({:quote => quote, :customer => customer, :price => price})
  end

  private

end

