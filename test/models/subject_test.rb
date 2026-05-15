require "test_helper"

class SubjectTest < ActiveSupport::TestCase
  test "invalid without name" do
    subject = Subject.new
    assert_not subject.valid?
  end

  test "unique name" do
    Subject.create!(name: "Física")
    subject2 = Subject.new(name: "Física")
    assert_not subject2.valid?
  end
end
