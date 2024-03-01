class ImportArchiveIds
  def self.import
    new.import
  end

  def import
    client = OpenTokClient.new.client
    affected = 0
    page = 0

    while page < 30
      client.archives.all(offset: 50 * page, count: 50).each do |a|
        affected += VideoChat
          .where("archive_id is null and session_id = :id or init_session_id = :id", id: a.session_id)
          .update_all(archive_id: a.id)
        affected += Booking
          .where("archive_id is null and session_id = :id or init_session_id = :id", id: a.session_id)
          .update_all(archive_id: a.id)
      end
      page += 1
    end

    puts "Updated: #{affected}"
  end
end
