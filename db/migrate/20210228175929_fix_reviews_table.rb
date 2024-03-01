class FixReviewsTable < ActiveRecord::Migration[5.2]
  def up
    execute(<<~SQL)
      alter table reviews
        alter column reviewer_name set not null;
      alter table reviews
        alter column rating set not null;
      alter table reviews
        alter column comment set not null;
      
      create index on reviews (user_id);
      create index on reviews (booking_id);
      create index on reviews (video_chat_id);
      create unique index on reviews(user_id, video_chat_id, reviewer_name);
      create unique index on reviews(user_id, booking_id, reviewer_name);

      alter table reviews
        add foreign key (user_id) references users;
      alter table reviews
        add foreign key (booking_id) references bookings;
      alter table reviews
        add foreign key (video_chat_id) references video_chats;
    SQL
  end

  def down
    execute(<<~SQL)
      alter table reviews
        drop constraint reviews_video_chat_id_fkey;
      alter table reviews
        drop constraint reviews_booking_id_fkey;
      alter table reviews
        drop constraint reviews_user_id_fkey;
      
      drop index reviews_user_id_booking_id_reviewer_name_idx;
      drop index reviews_user_id_video_chat_id_reviewer_name_idx;
      drop index reviews_video_chat_id_idx;
      drop index reviews_booking_id_idx;
      drop index reviews_user_id_idx;

      alter table reviews
        alter column comment drop not null;
      alter table reviews
        alter column rating drop not null;
      alter table reviews
        alter column reviewer_name drop not null;
    SQL
  end
end
