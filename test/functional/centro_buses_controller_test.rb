require 'test_helper'

class CentroBusesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => CentroBus.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    CentroBus.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    CentroBus.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to centro_bus_url(assigns(:centro_bus))
  end

  def test_edit
    get :edit, :id => CentroBus.first
    assert_template 'edit'
  end

  def test_update_invalid
    CentroBus.any_instance.stubs(:valid?).returns(false)
    put :update, :id => CentroBus.first
    assert_template 'edit'
  end

  def test_update_valid
    CentroBus.any_instance.stubs(:valid?).returns(true)
    put :update, :id => CentroBus.first
    assert_redirected_to centro_bus_url(assigns(:centro_bus))
  end

  def test_destroy
    centro_bus = CentroBus.first
    delete :destroy, :id => centro_bus
    assert_redirected_to centro_buses_url
    assert !CentroBus.exists?(centro_bus.id)
  end
end
