class QuotesController < ApplicationController

  # index : step one in the quote process
  def index
    @quote = nil
    @quote = Quote.new(session["quote"]) if session["quote"]
    @dents_collection = %w(1 2 3 4 5 6 7 8 9)
    @parts_collection = parts
    @prices = price_list

    # reset the session price
    session["price"] = nil
  end


  # review : step two in the quote process, review damage and collect customer info
  def review
    if session["quote"] && !params["quote"]
      @quote = Quote.new(session["quote"])
    elsif params && params["quote"]
      session["quote"] = params["quote"]
      @quote = Quote.new(session["quote"])
    end

    display_surcharge_message?

    @parts = pretty_parts
    @price = calculate_price
    @customer = Customer.new(session["customer"]) if session["customer"]

    if @price && @price == 0.00
      flash[:error] = "It seems you did not select any repairs to estimate.  Please try again."
      redirect_to quote_path
    end

    @service_area_collection = service_areas
    @days_of_week_collection = days_of_week
  end


  # step 3 : send the email, display a summary page that can be printed, and clean up session info
  def confirm

    if params && params["customer"]
      session["customer"] = params["customer"]
      @customer = Customer.new(session["customer"])
    else
      flash[:error] = "It seems that no contact information was submitted.  Please try again."
      redirect_to quote_review_path
    end

    if session["quote"]
      @quote = Quote.new(session["quote"])
      @price = calculate_price
      @parts = pretty_parts
      display_surcharge_message?
    end

    if @customer && @customer.valid? && @quote && @quote.valid? && @price && @price > 0.00

      flash[:info] = "Your estimate has been submitted.  You will be contacted shortly."

      # send email
      Notifications.deliver_quote(@quote, @customer, @price)

      # clean up
      session["quote"] = nil
      session["customer"] = nil
    else
      flash[:error] = "Some required information appears to be missing.  Please see the specific errors below."
      redirect_to quote_review_path
    end

  end

  private

    def price_list
      {
        :dent_1             => 99.00,
        :dent_2             => 139.00,
        :dent_3             => 169.00,
        :dent_4             => 199.00,
        :bumper_repair      => 375.00,
        :side_mirror_repair => 85.00,
        :paint_touch_up     => 150.00
      }
    end

    def calculate_price
      price = 0.00

      if @quote.nil?
        return price
      end

      prices = price_list

      # Paint Touch Ups don't get discount treatment
      price += @quote.bumper_repair.to_i        * prices[:bumper_repair]
      price += @quote.side_mirror_repair.to_i   * prices[:side_mirror_repair]
      price += @quote.paint_touch_up.to_i       * prices[:paint_touch_up]

      # Price the largest dent first and then take 50% off subsequent smaller dents
      if @quote.dent_4.to_i > 0
        prices[:dent_3] = prices[:dent_3] / 2
        prices[:dent_2] = prices[:dent_2] / 2
        prices[:dent_1] = prices[:dent_1] / 2
      elsif @quote.dent_3.to_i > 0
        prices[:dent_2] = prices[:dent_2] / 2
        prices[:dent_1] = prices[:dent_1] / 2
      elsif @quote.dent_2.to_i > 0
        prices[:dent_1] = prices[:dent_1] / 2
      end

      price += @quote.dent_4.to_i               * prices[:dent_4]
      price += @quote.dent_3.to_i               * prices[:dent_3]
      price += @quote.dent_2.to_i               * prices[:dent_2]
      price += @quote.dent_1.to_i               * prices[:dent_1]
    end

    def parts
      %w(trunk_lid hood roof tailgate lift_gate extra_cab hatch front_bumper rear_bumper right_mirror left_mirror
          left_front_fender left_front_door left_door left_right_door left_right_quarter_panel right_front_fender right_front_door right_door right_rear_door right_rear_quarter_panel)
    end

    def days_of_week
      %w(Monday Tuesday Wednesday Thursday Friday Saturday)
    end

    def service_areas
      r = []
      Location.find(:all, :select => :state).each {|s| r << s.state}
      r.uniq!
      r.sort!
    end

    def display_surcharge_message?
      if @quote.nil?
        @surcharge_message = nil
        return @surcharge_message
      end

      # display the surcharge warning message if
      # one of the following was checked
      if @quote.parts &&
         ( @quote.parts.include?("trunk_lid".humanize) ||
           @quote.parts.include?("hood".humanize)      ||
           @quote.parts.include?("roof".humanize)      ||
           @quote.parts.include?("tailgate".humanize)  ||
           @quote.parts.include?("lift_gate".humanize) )
        @surcharge_message = "Important Note : Prices may vary depending on the location and or severity of the damage."
      end
    end

    # clean up and display the array of parts in a nicer way
    def pretty_parts
      if @quote && !@quote.parts.blank?
        parts = @quote.parts
        parts = parts.delete_if {|x| x == "" || x == " "} # delete empty strings
        parts.compact! # remove nils
        parts.sort! # sort the array
        parts.map! {|h| h.humanize }
        parts = parts.join(", ") # return a comma + space separated string of parts
      else
        parts = nil
      end
    end

end

