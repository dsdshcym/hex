defmodule Hex.UtilsTest do
  use HexTest.Case, async: false

  setup do
    on_exit fn ->
      Enum.map([:http_proxy, :https_proxy], &(Hex.State.put(&1, nil)))
      Enum.map([:proxy, :https_proxy], fn opt ->
        :httpc.set_options([{opt, {{'localhost', 80}, ['localhost']}}], :hex)
      end)
    end

    :ok
  end

  test "proxy_config returns no credentials when no proxy supplied" do
    assert Hex.Utils.proxy_config("http://hex.pm") == []
  end

  test "proxy_config returns http_proxy credentials when supplied" do
    Hex.State.put(:http_proxy, "http://hex:test@example.com")

    assert Hex.Utils.proxy_config("http://hex.pm") == [proxy_auth: {'hex', 'test'}]
  end

  test "proxy_config returns http_proxy credentials when only username supplied" do
    Hex.State.put(:http_proxy, "http://nopass@example.com")

    assert Hex.Utils.proxy_config("http://hex.pm") == [proxy_auth: {'nopass', ''}]
  end

  test "proxy_config returns credentials when the protocol is https" do
    Hex.State.put(:https_proxy, "https://test:hex@example.com")

    assert Hex.Utils.proxy_config("https://hex.pm") == [proxy_auth: {'test', 'hex'}]
  end

  test "proxy_config returns empty list when no credentials supplied" do
    Hex.State.put(:http_proxy, "http://example.com")

    assert Hex.Utils.proxy_config("http://hex.pm") == []
  end
end
