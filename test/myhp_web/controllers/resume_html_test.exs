defmodule MyhpWeb.ResumeHTMLTest do
  use MyhpWeb.ConnCase, async: true
  import Phoenix.Template

  describe "resume HTML" do
    test "renders index template with resume available" do
      assigns = %{resume_exists: true}
      
      html = render_to_string(MyhpWeb.ResumeHTML, "index", "html", assigns)
      
      assert html =~ "Resume & CV"
      assert html =~ "View Online"
      assert html =~ "Download PDF"
    end
    
    test "renders index template when resume not available" do
      assigns = %{resume_exists: false}
      
      html = render_to_string(MyhpWeb.ResumeHTML, "index", "html", assigns)
      
      assert html =~ "Resume Coming Soon"
      assert html =~ "View My Portfolio"
      assert html =~ "Contact Me"
    end
  end
end