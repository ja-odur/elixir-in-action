defmodule Server do
  def start do
    spawn(fn -> loop() end)
  end

  def send_message(server, message) do
    send(server, {self(), message})

    receive do
      {:response, response} -> response
    end
  end

  def loop do
    receive do
      {caller, message} ->
        Process.sleep(1000)
        send(caller, {:response, message})
    end

    loop()
  end
end
