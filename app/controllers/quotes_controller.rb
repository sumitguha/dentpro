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
      @quote.pretty_parts = @parts

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

      price += @quote.bumper_repair.to_i        * prices[:bumper_repair]
      price += @quote.side_mirror_repair.to_i   * prices[:side_mirror_repair]
      price += @quote.paint_touch_up.to_i       * prices[:paint_touch_up]

      # Price the largest dent first and then take 50% (N * 0.50) off subsequent smaller dents
      discount_multiplier = 0.50
      num_dents = 0

      if @quote.dent_4
        1.upto(@quote.dent_4.to_i).each {|dent|
          if num_dents == 0
            price += prices[:dent_4]
          else
            price += prices[:dent_4] * discount_multiplier
          end
          num_dents += 1
        }
      end

      if @quote.dent_3
        1.upto(@quote.dent_3.to_i).each {|dent|
          if num_dents == 0
            price += prices[:dent_3]
          else
            price += prices[:dent_3] * discount_multiplier
          end
          num_dents += 1
        }
      end

      if @quote.dent_2
        1.upto(@quote.dent_2.to_i).each {|dent|
          if num_dents == 0
            price += prices[:dent_2]
          else
            price += prices[:dent_2] * discount_multiplier
          end
          num_dents += 1
        }
      end

      if @quote.dent_1
        1.upto(@quote.dent_1.to_i).each {|dent|
          if num_dents == 0
            price += prices[:dent_1]
          else
            price += prices[:dent_1] * discount_multiplier
          end
          num_dents += 1
        }
      end

      # The self-declared Club DentPro members get an *additional* %25 discount (N * 0.75) on
      # the total estimate price (ALL repairs, not just Dents).
      if club_dentpro?
        price = price * 0.75
      else
        return price
      end

    end

    # optionally pass in a string or symbol which is the hash key you want e.g. parts(:left) or parts("left")
    # if no param passed the entire parts hash is returned.
    def parts(location = nil)
      parts = {
        :left   => %w(left_mirror left_front_fender left_front_door left_door left_rear_door left_rear_quarter_panel),
        :right  => %w(right_mirror  right_front_fender right_front_door right_door right_rear_door right_rear_quarter_panel),
        :other  => %w(trunk_lid hood roof tailgate lift_gate extra_cab hatch front_bumper rear_bumper)
      }
      location.nil? ? parts : parts[location.to_sym]
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
      if @quote.parts_other && ( @quote.parts_other.include?("trunk_lid".humanize)    ||
                                 @quote.parts_other.include?("hood".humanize)         ||
                                 @quote.parts_other.include?("roof".humanize)         ||
                                 @quote.parts_other.include?("tailgate".humanize)     ||
                                 @quote.parts_other.include?("lift_gate".humanize)    ||
                                 @quote.parts_other.include?("extra_cab".humanize)    ||
                                 @quote.parts_other.include?("hatch".humanize)        ||
                                 @quote.parts_other.include?("front_bumper".humanize) ||
                                 @quote.parts_other.include?("rear_bumper".humanize)
                               )
        @surcharge_message = "Important Note : Prices may vary depending on the location and or severity of the damage."
      end
    end

    # merge, clean up and display the array of parts in a nicer way
    def pretty_parts

      resp = nil

      ["left", "right", "other"].each do |loc|
        location = ("parts_" + loc).to_sym
        if @quote && !@quote.send(location).blank?
          parts = @quote.send(location)
          parts = parts.delete_if {|x| x == "" || x == " "} # delete empty strings
          parts.compact! # remove nils
          parts.sort! # sort the array
          parts.map! {|h| h.humanize }
          parts = parts.join(", ") # comma + space separated string of parts
          if resp.blank?
            resp = parts unless parts.blank?
          else
            resp += (", " + parts) unless parts.blank?
          end
        end
      end

      return resp
    end

    def club_dentpro?
      @quote.club_dentpro_member == "1" ? true : false
    end

end

