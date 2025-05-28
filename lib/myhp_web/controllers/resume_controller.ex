defmodule MyhpWeb.ResumeController do
  use MyhpWeb, :controller

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
