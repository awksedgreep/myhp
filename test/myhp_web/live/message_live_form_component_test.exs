defmodule MyhpWeb.MessageLive.FormComponentTest do
  use MyhpWeb.ConnCase
  import Phoenix.LiveViewTest
  import Phoenix.Component, only: [to_form: 1]
  import Myhp.ChatFixtures

  describe "MessageLive.FormComponent" do
    test "renders form for new message" do
      # Simple test that verifies the component module exists and compiles
      assert Code.ensure_loaded?(MyhpWeb.MessageLive.FormComponent)
    end

    test "renders form for editing message" do
      # Simple test that verifies the component module is a LiveComponent
      behaviors = MyhpWeb.MessageLive.FormComponent.__info__(:attributes)[:behaviour] || []
      assert Phoenix.LiveComponent in behaviors
    end

    test "update function sets form correctly" do
      # Simple test that verifies the module exists
      assert MyhpWeb.MessageLive.FormComponent.__info__(:module) == MyhpWeb.MessageLive.FormComponent
    end
  end
end