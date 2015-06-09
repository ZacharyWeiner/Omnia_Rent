require 'test_helper'

class LocalitiesControllerTest < ActionController::TestCase
  setup do
    @locality = localities(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:localities)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create locality" do
    assert_difference('Locality.count') do
      post :create, locality: { city_id: @locality.city_id, code: @locality.code, name: @locality.name }
    end

    assert_redirected_to locality_path(assigns(:locality))
  end

  test "should show locality" do
    get :show, id: @locality
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @locality
    assert_response :success
  end

  test "should update locality" do
    patch :update, id: @locality, locality: { city_id: @locality.city_id, code: @locality.code, name: @locality.name }
    assert_redirected_to locality_path(assigns(:locality))
  end

  test "should destroy locality" do
    assert_difference('Locality.count', -1) do
      delete :destroy, id: @locality
    end

    assert_redirected_to localities_path
  end
end
