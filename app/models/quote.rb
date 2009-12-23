class Quote < PassiveRecord::Base
  include Validatable

  belongs_to :customer
  define_fields :dent_1, :dent_2, :dent_3, :dent_4,
                :bumper_repair, :side_mirror_repair, :paint_touch_up,
                :parts_left, :parts_right, :parts_other, :pretty_parts

end

