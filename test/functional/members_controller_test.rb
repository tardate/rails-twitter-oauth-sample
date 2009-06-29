require 'test_helper'

class MembersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:members)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create member" do
    assert_difference('Member.count') do
      post :create, :member => { }
    end

    assert_redirected_to member_path(assigns(:member))
  end

  test "should show member" do
    get :show, :id => members(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => members(:one).id
    assert_response :success
  end

  test "should update member" do
    put :update, :id => members(:one).id, :member => { }
    assert_redirected_to member_path(assigns(:member))
  end

  test "should destroy member" do
    assert_difference('Member.count', -1) do
      delete :destroy, :id => members(:one).id
    end

    assert_redirected_to members_path
  end
end
