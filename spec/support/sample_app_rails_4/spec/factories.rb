FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    email    { "person_#{rand(10000)}@example.com"}
    password "foobar"
    password_confirmation "foobar"

    factory :admin do
      admin true
    end
  end

  factory :micropost do
    content "Lorem ipsum"
    user
  end
end
