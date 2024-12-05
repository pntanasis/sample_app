require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    post login_path, params: { session: { email: @user.email, password: "password" } }
  end

  test "unsuccessful edit" do
    get edit_user_path(@user)
    assert_template "users/edit"
    patch user_path(@user), params: { user: { name: "", email: "foo@invalid", password: "foo",
                                               password_confirmation: "bar" } }
    assert_template "users/edit"
  end

  test "successful edit with friendly forwarding" do
    # While logged out, fail to access the edit page and then after login, you should be redirected to the edit page
    delete logout_path
    get edit_user_path(@user)
    post login_path, params: { session: { email: @user.email, password: "password" } }
    assert_redirected_to edit_user_url(@user)
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name: name, email: email, password: "", password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test "should redirect edit when not logged in" do
    delete logout_path
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    delete logout_path
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

end
