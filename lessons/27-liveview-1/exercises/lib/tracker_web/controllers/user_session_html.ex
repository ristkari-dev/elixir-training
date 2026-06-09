defmodule TrackerWeb.UserSessionHTML do
  use TrackerWeb, :html

  embed_templates "user_session_html/*"

  defp local_mail_adapter? do
    Application.get_env(:tracker, Tracker.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
