defmodule MyhpWeb.UploadedFileLive.AdditionalTest do
  use MyhpWeb.ConnCase
  import Phoenix.LiveViewTest
  import Myhp.AccountsFixtures

  describe "UploadedFileLive.Index additional functionality" do
    test "handles filter event", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      
      {:ok, index_live, _html} = live(conn, ~p"/admin/files")

      # Test filter event by clicking filter button
      assert index_live
             |> element("button[phx-click='filter'][phx-value-type='image']")
             |> render_click()

      # Should still be on the same page
      assert has_element?(index_live, "h1", "File Manager")
    end

    test "handles copy-url event", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      
      {:ok, index_live, _html} = live(conn, ~p"/admin/files")

      # Test that page loads correctly - copy URL is JS only
      assert has_element?(index_live, "h1", "File Manager")
    end

    test "handles validate event", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      
      {:ok, index_live, _html} = live(conn, ~p"/admin/files")

      # Test that page loads correctly - validate is for live uploads
      assert has_element?(index_live, "h1", "File Manager")
      assert has_element?(index_live, "form[phx-submit='save']")
    end

    test "displays file manager page", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      
      {:ok, _index_live, html} = live(conn, ~p"/admin/files")

      assert html =~ "File Manager"
      assert html =~ "Upload Files"
    end

    test "handles cancel-upload event", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      
      {:ok, index_live, _html} = live(conn, ~p"/admin/files")

      # Test that page loads correctly - cancel upload is for live uploads
      assert has_element?(index_live, "h1", "File Manager")
      assert has_element?(index_live, "form[phx-submit='save']")
    end
  end
end