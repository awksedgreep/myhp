defmodule MyhpWeb.UploadedFileLive.Index do
  use MyhpWeb, :live_view
  alias Myhp.Uploads
  alias Myhp.Uploads.UploadedFile

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "File Manager")
      |> assign(:current_page, "admin")
      |> assign(:uploaded_files, list_uploaded_files(socket))
      |> assign(:upload_stats, Uploads.upload_stats())
      |> assign(:filter_type, "all")
      |> allow_upload(:files,
        accept: ~w(.jpg .jpeg .png .gif .pdf .doc .docx .txt .md),
        max_entries: 10,
        max_file_size: 10_000_000
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit File")
    |> assign(:uploaded_file, Uploads.get_uploaded_file!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Upload Files")
    |> assign(:uploaded_file, %UploadedFile{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "File Manager")
    |> assign(:uploaded_file, nil)
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :files, ref)}
  end

  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :files, fn %{path: path} = _meta, entry ->
        # Create a temporary upload entry structure
        upload_entry = %{
          path: path,
          client_name: entry.client_name,
          client_type: entry.client_type
        }

        case Uploads.handle_upload(upload_entry, socket.assigns.current_user.id) do
          {:ok, uploaded_file} -> {:ok, uploaded_file}
          {:error, reason} -> {:error, reason}
        end
      end)

    case uploaded_files do
      [] ->
        {:noreply, socket}

      files when is_list(files) ->
        success_count =
          Enum.count(files, fn
            {:ok, _} -> true
            _ -> false
          end)

        socket =
          socket
          |> update(:uploaded_files, fn _ -> list_uploaded_files(socket) end)
          |> assign(:upload_stats, Uploads.upload_stats())
          |> put_flash(:info, "Successfully uploaded #{success_count} file(s)")

        {:noreply, push_patch(socket, to: ~p"/admin/files")}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    uploaded_file = Uploads.get_uploaded_file!(id)
    {:ok, _} = Uploads.delete_uploaded_file(uploaded_file)

    socket =
      socket
      |> update(:uploaded_files, fn _ -> list_uploaded_files(socket) end)
      |> assign(:upload_stats, Uploads.upload_stats())
      |> put_flash(:info, "File deleted successfully")

    {:noreply, socket}
  end

  def handle_event("filter", %{"type" => type}, socket) do
    socket =
      socket
      |> assign(:filter_type, type)
      |> assign(:uploaded_files, list_uploaded_files(socket, type))

    {:noreply, socket}
  end

  def handle_event("copy-url", %{"url" => url}, socket) do
    {:noreply, push_event(socket, "copy-to-clipboard", %{text: url})}
  end

  @impl true
  def handle_info({MyhpWeb.UploadedFileLive.FormComponent, {:saved, _uploaded_file}}, socket) do
    socket =
      socket
      |> assign(:uploaded_files, list_uploaded_files(socket))
      |> assign(:upload_stats, Uploads.upload_stats())

    {:noreply, socket}
  end

  defp list_uploaded_files(_socket, filter_type \\ "all") do
    case filter_type do
      "all" -> Uploads.list_uploaded_files()
      type -> Uploads.list_uploaded_files_by_type(type)
    end
  end

  defp format_file_size(size) when size < 1024, do: "#{size} B"
  defp format_file_size(size) when size < 1024 * 1024, do: "#{Float.round(size / 1024, 1)} KB"

  defp format_file_size(size) when size < 1024 * 1024 * 1024,
    do: "#{Float.round(size / (1024 * 1024), 1)} MB"

  defp format_file_size(size), do: "#{Float.round(size / (1024 * 1024 * 1024), 1)} GB"

  defp file_icon(file_type) do
    case file_type do
      "image" -> "hero-photo"
      "document" -> "hero-document-text"
      _ -> "hero-document"
    end
  end

  defp error_to_string(:too_large), do: "File too large"
  defp error_to_string(:too_many_files), do: "Too many files"
  defp error_to_string(:not_accepted), do: "File type not accepted"
  defp error_to_string(error), do: "Upload error: #{error}"
end
