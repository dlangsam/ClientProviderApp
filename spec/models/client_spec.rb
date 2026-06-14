require 'rails_helper'

RSpec.describe Client, type: :model do
  describe 'validations' do
    subject { build(:client) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    describe 'name' do
      it 'is required' do
        subject.name = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:name]).to include("can't be blank")
      end
    end

    describe 'email' do
      it 'is required' do
        subject.email = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:email]).to include("can't be blank")
      end

      it 'validates email format' do
        subject.email = 'invalid-email'
        expect(subject).not_to be_valid
        expect(subject.errors[:email]).to be_present
      end

      it 'accepts valid email addresses' do
        valid_emails = ['user@example.com', 'test.user+tag@domain.co.uk']
        valid_emails.each do |email|
          subject.email = email
          expect(subject).to be_valid
        end
      end

      it 'enforces uniqueness (case-insensitive)' do
        create(:client, email: 'test@example.com')
        subject.email = 'TEST@example.com'
        expect(subject).not_to be_valid
        expect(subject.errors[:email]).to include('has already been taken')
      end
    end
  end
end
