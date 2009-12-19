class Customer < PassiveRecord::Base
  include Validatable
  has_many :quotes
  define_fields :name, :title, :company, :phone,
                :email, :address, :address2, :city,
                :state, :zip, :service_area, :day_of_week,
                :time_of_day

  validates_presence_of :name, :phone, :email, :address, :city, :state, :zip

end

