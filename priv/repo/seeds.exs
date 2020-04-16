{:ok, _user} =
  HeyCake.Users.create(%{
    email: "user@example.com",
    first_name: "John",
    last_name: "Smith",
    password: "password",
    password_confirmation: "password"
  })
