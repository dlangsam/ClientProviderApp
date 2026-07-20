require 'rails_helper'

RSpec.describe Note, type: :model do
  describe 'associations' do
    it 'belongs to a client' do
      note = create(:note)
      expect(note.client).to be_a(Client)
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      note = build(:note)
      expect(note).to be_valid
    end

    it 'requires content' do
      note = build(:note, content: nil)
      expect(note).not_to be_valid
      expect(note.errors[:content]).to include("can't be blank")
    end
  end

  describe 'scopes' do
    it 'sorts notes by date descending' do
      client = create(:client)
      note1 = create(:note, client: client, created_at: 2.days.ago)
      note2 = create(:note, client: client, created_at: 1.day.ago)
      note3 = create(:note, client: client, created_at: Time.current)

      notes = Note.sorted_by_date
      expect(notes).to eq([ note3, note2, note1 ])
    end
  end
end
