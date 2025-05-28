defmodule MyhpWeb.ResumeControllerTest do
  use MyhpWeb.ConnCase

  setup do
    # Create a test resume file for testing
    resume_dir = Path.join([Application.app_dir(:myhp), "priv", "static"])
    File.mkdir_p!(resume_dir)
    test_resume_path = Path.join(resume_dir, "resume.pdf")
    
    # Create a minimal PDF-like content for testing
    test_content = "%PDF-1.4\n1 0 obj\n<<\n/Type /Catalog\n/Pages 2 0 R\n>>\nendobj\n"
    File.write!(test_resume_path, test_content)
    
    on_exit(fn ->
      if File.exists?(test_resume_path) do
        File.rm!(test_resume_path)
      end
    end)
    
    %{resume_path: test_resume_path}
  end

  describe "GET /resume/download" do
    test "downloads resume file when it exists", %{conn: conn} do
      conn = get(conn, ~p"/resume/download")
      
      assert response(conn, 200)
      assert get_resp_header(conn, "content-type") == ["application/pdf; charset=utf-8"]
      assert get_resp_header(conn, "content-disposition") == 
               ["attachment; filename=\"Mark_Cotner_Resume.pdf\""]
      
      # Check that response contains PDF content
      assert response(conn, 200) =~ "%PDF"
    end

    test "redirects to home when resume file missing", %{conn: conn, resume_path: resume_path} do
      # Remove the test file
      File.rm!(resume_path)
      
      conn = get(conn, ~p"/resume/download")
      
      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Resume file not found"
    end
  end

  describe "GET /resume" do
    test "displays resume file inline when it exists", %{conn: conn} do
      conn = get(conn, ~p"/resume")
      
      assert response(conn, 200)
      assert get_resp_header(conn, "content-type") == ["application/pdf; charset=utf-8"]
      assert get_resp_header(conn, "content-disposition") == 
               ["inline; filename=\"Mark_Cotner_Resume.pdf\""]
      
      # Check that response contains PDF content
      assert response(conn, 200) =~ "%PDF"
    end

    test "redirects to home when resume file missing", %{conn: conn, resume_path: resume_path} do
      # Remove the test file
      File.rm!(resume_path)
      
      conn = get(conn, ~p"/resume")
      
      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Resume file not found"
    end
  end

  describe "GET /cv" do
    test "cv route works as alias for resume view", %{conn: conn} do
      conn = get(conn, ~p"/cv")
      
      assert response(conn, 200)
      assert get_resp_header(conn, "content-type") == ["application/pdf; charset=utf-8"]
      assert get_resp_header(conn, "content-disposition") == 
               ["inline; filename=\"Mark_Cotner_Resume.pdf\""]
    end
  end

  describe "GET /cv/download" do
    test "cv download route works as alias for resume download", %{conn: conn} do
      conn = get(conn, ~p"/cv/download")
      
      assert response(conn, 200)
      assert get_resp_header(conn, "content-type") == ["application/pdf; charset=utf-8"]
      assert get_resp_header(conn, "content-disposition") == 
               ["attachment; filename=\"Mark_Cotner_Resume.pdf\""]
    end
  end
end