class Notifications < ActionMailer::Base


  def quote(quote = nil, customer = nil, price = nil, sent_at = Time.now )
    subject    'DentPro Appointment Request'
    recipients DENTPRO_EMAIL_RECIPIENTS
    from       DENTPRO_EMAIL_FROM
    sent_on    sent_at

    # format parts array in a nicer way
    quote.parts = pretty_parts(quote)

    body({:quote => quote, :customer => customer, :price => price})
  end

  private

    def pretty_parts(quote)
      if quote.parts
        parts = quote.parts
        parts = parts.delete_if {|x| x == "" || x == " "}
        parts.compact!
        parts.sort!
        parts.map! {|h| h.humanize }
        parts = parts.join(", ")
      end
    end

end

