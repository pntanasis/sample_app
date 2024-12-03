require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:michael)
    post login_path, params: { session: { email: @user.email, password: "password" } }
    @other_user = users(:archer)

  end

  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: { user: { email: "new@example.com", name: "New User", password: "password",
                                        password_confirmation: "password" } }
    end

    assert_redirected_to user_url(User.last)
  end

  test "should show user" do
    get user_url(@user)
    assert_response :success
  end

  test "should get edit" do
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    patch user_url(@user), params: { user: { email: @user.email, name: @user.name } }
    assert_redirected_to user_url(@user)
  end

  test "should destroy user" do
    assert_difference("User.count", -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end

  test "should redirect edit when logged in as wrong user" do
    delete logout_path
    post login_path, params: { session: { email: @other_user.email, password: "password" } }
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    delete logout_path
    post login_path, params: { session: { email: @other_user.email, password: "password" } }
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect index when not logged in" do
    delete logout_path
    get users_path
    assert_redirected_to login_url
  end

  test "should not allow the admin attribute to be edited via the web" do
    post login_path, params: { session: { email: @other_user.email, password: "password" } }
    assert_not @other_user.admin?
    patch user_path(@other_user), params: {
      user: {admin: true } }
    assert_not @other_user.admin?
  end

  test "should redirect destroy when not logged in" do
    delete logout_path
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    post login_path, params: { session: { email: @other_user.email, password: "password" } }
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end


end
