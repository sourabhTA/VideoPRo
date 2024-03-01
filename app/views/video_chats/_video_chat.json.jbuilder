json.extract! video_chat, :id, :user_id, :name, :session_id, :archive_id, :created_at, :updated_at
json.url video_chat_url(video_chat, format: :json)
