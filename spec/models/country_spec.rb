require 'rails_helper'

RSpec.describe Country, :type => :model do
  let(:country) { FactoryGirl.build(:country) }

  context 'validations' do
    it { expect(country).to validate_uniqueness_of(:iso_alpha_2) }
  end
end
