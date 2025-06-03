defmodule MyhpWeb.ResumeHTML do
  @moduledoc """
  This module contains pages rendered by ResumeController.
  """
  use MyhpWeb, :html

  embed_templates "resume_html/*"
end