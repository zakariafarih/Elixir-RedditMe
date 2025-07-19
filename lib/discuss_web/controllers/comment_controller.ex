defmodule DiscussWeb.CommentController do
  use DiscussWeb, :controller

  alias Discuss.Content
  alias Discuss.Content.Comment

  def edit(conn, %{"topic_id" => topic_id, "id" => comment_id}) do
    topic = Content.get_topic!(topic_id)
    comment = Content.get_comment!(comment_id)

    # Ensure the comment belongs to this topic and the current user can edit it
    if comment.topic_id != String.to_integer(topic_id) do
      conn
      |> put_flash(:error, "Comment not found for this topic.")
      |> redirect(to: ~p"/topics/#{topic_id}")
    else
      if comment.user_id != conn.assigns.current_user.id do
        conn
        |> put_flash(:error, "You can only edit your own comments.")
        |> redirect(to: ~p"/topics/#{topic_id}")
      else
        changeset = Content.change_comment(comment)
        render(conn, :edit, topic: topic, comment: comment, changeset: changeset)
      end
    end
  end

  def update(conn, %{"topic_id" => topic_id, "id" => comment_id, "comment" => comment_params}) do
    topic = Content.get_topic!(topic_id)
    comment = Content.get_comment!(comment_id)

    # Ensure the comment belongs to this topic and the current user can edit it
    if comment.topic_id != String.to_integer(topic_id) do
      conn
      |> put_flash(:error, "Comment not found for this topic.")
      |> redirect(to: ~p"/topics/#{topic_id}")
    else
      if comment.user_id != conn.assigns.current_user.id do
        conn
        |> put_flash(:error, "You can only edit your own comments.")
        |> redirect(to: ~p"/topics/#{topic_id}")
      else
        case Content.update_comment(comment, comment_params) do
          {:ok, _comment} ->
            conn
            |> put_flash(:info, "Comment updated successfully.")
            |> redirect(to: ~p"/topics/#{topic_id}/comments_live")

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, :edit, topic: topic, comment: comment, changeset: changeset)
        end
      end
    end
  end

  def delete(conn, %{"topic_id" => topic_id, "id" => comment_id}) do
    comment = Content.get_comment!(comment_id)

    # Ensure the comment belongs to this topic and the current user can delete it
    if comment.topic_id != String.to_integer(topic_id) do
      conn
      |> put_flash(:error, "Comment not found for this topic.")
      |> redirect(to: ~p"/topics/#{topic_id}")
    else
      if comment.user_id != conn.assigns.current_user.id do
        conn
        |> put_flash(:error, "You can only delete your own comments.")
        |> redirect(to: ~p"/topics/#{topic_id}")
      else
        {:ok, _comment} = Content.delete_comment(comment)

        conn
        |> put_flash(:info, "Comment deleted successfully.")
        |> redirect(to: ~p"/topics/#{topic_id}/comments_live")
      end
    end
  end
end
