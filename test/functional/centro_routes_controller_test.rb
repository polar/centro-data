require 'test_helper'

class CentroRoutesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => CentroRoutes.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    CentroRoutes.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    CentroRoutes.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to centro_routes_url(assigns(:centro_routes))
  end

  def test_edit
    get :edit, :id => CentroRoutes.first
    assert_template 'edit'
  end

  def test_update_invalid
    CentroRoutes.any_instance.stubs(:valid?).returns(false)
    put :update, :id => CentroRoutes.first
    assert_template 'edit'
  end

  def test_update_valid
    CentroRoutes.any_instance.stubs(:valid?).returns(true)
    put :update, :id => CentroRoutes.first
    assert_redirected_to centro_routes_url(assigns(:centro_routes))
  end

  def test_destroy
    centro_routes = CentroRoutes.first
    delete :destroy, :id => centro_routes
    assert_redirected_to centro_routes_url
    assert !CentroRoutes.exists?(centro_routes.id)
  end
end
