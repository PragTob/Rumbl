defmodule Rumbl.VideoViewTest do
  use Rumbl.ConnCase, async: true
  alias Rumbl.Video
  import Phoenix.View

  test "renders index.html", %{conn: conn} do
    videos = [%Video{id: 1, title: "dogs"}, %Video{id: 2, title: "more dogs"}]
    content = render_to_string(Rumbl.VideoView, "index.html", conn: conn, videos: videos)

    assert String.contains?(content, "Listing videos")
    for video <- videos do
      assert String.contains?(content, video.title)
    end
  end

  test "renders new.html", %{conn: conn} do
    changeset = Rumbl.Video.changeset %Rumbl.Video{}
    categories = ["dogs", 42]
    content = render_to_string(Rumbl.VideoView, "new.html", conn: conn, changeset: changeset, categories: categories)

    assert String.contains?(content, "New video")
  end
end
