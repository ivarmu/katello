# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::ContentViewFilterBulkRulesControllerTest < ActionController::TestCase
    def models
      @filter = katello_content_view_filters(:simple_filter)
      @rule = katello_content_view_package_filter_rules(:test_package)
      @rule_for_different_filter = katello_content_view_package_filter_rules(:package_rule)
    end

    def permissions
      @view_permission = :view_content_views
      @create_permission = :create_content_views
      @update_permission = :edit_content_views
      @destroy_permission = :destroy_content_views
    end

    def setup
      setup_controller_defaults_api
      models
      permissions
    end

    def test_index
      get :index, params: { :content_view_filter_id => @filter.id }

      assert_response :success
      assert_template 'api/v2/content_view_filter_bulk_rules/index'
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, params: { :content_view_filter_id => @filter.id }
      end
    end

    def test_create
      post :create, params: { :content_view_filter_id => @filter.id, :data => [
                                                                               {'name': 'name1',
                                                                                'version': 'ver1',
                                                                                'architecture': 'arch1'
                                                                               }
                                                                              ]
                            }

      assert_response :success

      assert_template :layout => 'katello/api/v2/layouts/resource'
      assert_template 'katello/api/v2/common/create'
      assert_equal @filter.reload.package_rules.second.name, "name1"
      assert_equal @filter.package_rules.second.version, "ver1"
    end

    def test_create_with_name_array
      post :create, params: { :content_view_filter_id => @filter.id, :data => [
                                                                               {'name': 'name1',
                                                                                'version': 'ver1',
                                                                                'architecture': 'arch1'
                                                                               },
                                                                               {'name': 'name2',
                                                                                'version': 'ver2',
                                                                                'architecture': 'arch2'
                                                                               }
                                                                              ]
                            }

      assert_response :success

      assert_template layout: 'katello/api/v2/layouts/collection'
      assert_template 'katello/api/v2/content_view_filter_bulk_rules/index'
      assert_equal @filter.reload.package_rules.sort.map(&:name), %w(package\ def name1 name2)
      assert_equal @filter.package_rules.map(&:version), %w(ver1 ver2)
    end

      assert_response :success

      assert_template layout: 'katello/api/v2/layouts/collection'
      assert_template 'katello/api/v2/content_view_filter_bulk_rules/index'
      assert_equal @filter.reload.package_rules.sort.map(&:name), %w(name1 name2)
      assert_equal @filter.package_rules.map(&:version), %w(ver1 ver2)
      assert_equal @filter.package_rules.map(&:architecture), %w(arch1 arch2)
    end

      assert_response :success

      assert_template layout: 'katello/api/v2/layouts/collection'
      assert_template 'katello/api/v2/content_view_filter_bulk_rules/index'
      assert_equal @filter.reload.package_rules.sort.map(&:name), %w(name1 name2)
      assert_equal @filter.package_rules.map(&:version), %w(ver1 ver2)
      assert_equal @filter.package_rules.map(&:architecture), %w(arch1 arch2)
    end

    def test_create_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create, params: { :content_view_filter_id => @filter.id, :data => [
                                                                                 {'name': 'name1',
                                                                                  'version': 'ver1',
                                                                                  'architecture': 'arch1'
                                                                                 }
                                                                                ]
                              }
      end
    end

    def test_show
      get :show, params: { :content_view_filter_id => @filter.id, :id => @rule.id }

      assert_response :success
      assert_template 'api/v2/content_view_filter_bulk_rules/show'
    end

    def test_mismatched_filter_and_rule
      get :show, params: { :content_view_filter_id => @filter.id, :id => @rule_for_different_filter.id }

      assert_response 404
    end

    def test_show_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, params: { :content_view_filter_id => @filter.id, :id => @rule.id }
      end
    end


    def test_destroy
      delete :destroy, params: { :content_view_filter_id => @filter.id, :id => @rule.id }

      results = JSON.parse(response.body)
      refute results.blank?
      assert_equal results['id'], @rule.id

      assert_response :success
      assert_nil ContentViewPackageFilterRule.find_by_id(@rule.id)
    end

    def test_destroy_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, params: { :content_view_filter_id => @filter.id, :id => @rule.id }
      end
    end
  end
end
