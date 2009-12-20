class Location < ActiveRecord::Base
  validates_presence_of :name, :on => :save, :message => "can't be blank"
  #validates_presence_of :street, :on => :save, :message => "can't be blank"
  #validates_presence_of :city, :on => :save, :message => "can't be blank"
  validates_presence_of :state, :on => :save, :message => "can't be blank"
  #validates_presence_of :zip, :on => :save, :message => "can't be blank"
  #validates_presence_of :region, :on => :save, :message => "can't be blank"
  validates_presence_of :phone1, :on => :save, :message => "can't be blank"
end
