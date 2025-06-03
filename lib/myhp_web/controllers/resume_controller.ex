defmodule MyhpWeb.ResumeController do
  use MyhpWeb, :controller

  def index(conn, _params) do
    resume_path = Application.app_dir(:myhp, "priv/static/resume.pdf")
    resume_exists = File.exists?(resume_path)
    
    conn
    |> assign(:page_title, "Resume")
    |> assign(:current_page, "resume")
    |> assign(:resume_exists, resume_exists)
    |> render(:index)
  end

  def download(conn, _params) do
    resume_path = Application.app_dir(:myhp, "priv/static/resume.pdf")

    case File.exists?(resume_path) do
      true ->
        conn
        |> put_resp_content_type("application/pdf")
        |> put_resp_header(
          "content-disposition",
          "attachment; filename=\"Mark_Cotner_Resume.pdf\""
        )
        |> send_file(200, resume_path)

      false ->
        conn
        |> put_flash(:error, "Resume file not found. Please contact the site administrator.")
        |> redirect(to: ~p"/")
    end
  end

  def view(conn, _params) do
    resume_path = Application.app_dir(:myhp, "priv/static/resume.pdf")

    case File.exists?(resume_path) do
      true ->
        conn
        |> put_resp_content_type("application/pdf")
        |> put_resp_header("content-disposition", "inline; filename=\"Mark_Cotner_Resume.pdf\"")
        |> send_file(200, resume_path)

      false ->
        conn
        |> put_flash(:error, "Resume file not found. Please contact the site administrator.")
        |> redirect(to: ~p"/")
    end
  end
end
