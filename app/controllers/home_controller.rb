class HomeController < ApplicationController

  def index
  end

  def contact_us
  end

  def who_we_are
    # Used to display the number of locations and states in the 'Company Background' section.
    locations = Location.find(:all, :order => 'state, name ASC')
    states = []
    locations.each do |loc|
      states << loc.state unless loc.state.nil?
    end

    # degrade gracefully if we have not yet defined any locations in the DB
    # Makes use of the numbersToWords plugin:
    # http://github.com/accidental/numbersToWords
    if states && states.length >= 1 && locations && locations.length >= 1
      @locations = locations.length.to_english
      @states = states.length.to_english
    else
      @locations = "many"
      @states = "most of the western"
    end

  end

  def what_we_do
  end

end

