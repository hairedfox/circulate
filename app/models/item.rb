class Item < ApplicationRecord
  audited

  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations
  has_many :loans, dependent: :destroy
  has_one :active_loan, -> { where("ended_at IS NULL").readonly }, class_name: "Loan"

  has_rich_text :description
  has_one_attached :image

  validates :name, presence: true
  validates :number, presence: true, numericality: { only_integer: true },  uniqueness: true

  before_validation :assign_number, on: :create

  def self.next_number
    last_item = order("number DESC NULLS LAST").limit(1).first
    return 1 unless last_item
    last_item.number.to_i + 1
  end

  def assign_number
    if number.blank?
      self.number = self.class.next_number
    end
  end

  def due_on
    active_loan.due_at.to_date
  end

  def available?
    !active_loan.present?
  end
end