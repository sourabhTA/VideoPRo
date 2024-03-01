update bank_accounts
  set account_number = '000000',
      routing_number = '000000',
      account_holder_name = 'Luke S. Walker '|| bank_accounts.user_id,
      stripe_bank_account_id = '0000000';

update clients
  set email = first_name || '@example.com',
      last_name = 'Walker',
      phone_number = '1-800-555-0100',
      token = null;

update contacts
  set name = split_part(name, ' ', 1),
      email = split_part(name, ' ', 1) || '@example.com';

update reviews
  set comment = 'Great job 👍';

update scheduled_services
  set email_address = 'info@example.com',
      phone_number = '1-800-555-0100',
      owner_name = 'Owner Name',
      your_name = 'Your Name',
      property_address = '123 Street';

update admin_users
  set encrypted_password = '$2a$11$vgSQLOqtXmaUq6NXVPvkwuDc9jrBh12k2iBMslNozPjEdrj2AOZVu'; -- password

update users
  set email = id || '@example.com',
      encrypted_password = '$2a$11$vgSQLOqtXmaUq6NXVPvkwuDc9jrBh12k2iBMslNozPjEdrj2AOZVu', -- password
      name = id || '-Luke S Walker',
      phone_number = '1-800-555-0100',
      business_website = 'http://example.com',
      reset_password_token = null,
      reset_password_sent_at = null,
      current_sign_in_ip = null,
      last_sign_in_ip = null,
      confirmation_token = null,
      confirmation_sent_at = null,
      stripe_customer_id = null,
      stripe_subscription_id = null,
      stripe_payment_id = null,
      business_address = null,
      address = '123 Street, New New Mexico',
      reminder_count = 10,
      facebook_url = 'http://example.com?fb=1',
      twitter_url = 'http://example.com?twitter=1',
      instagram_url = 'http://example.com?instagram=1',
      youtube_url = 'http://example.com?youtube=1',
      linkedin_url = 'http://example.com?linkedin=1',
      video_url = null,
      stripe_custom_account_id = null,
      google_my_business = null,
      business_number = '1-800-555-0100',
      scrapped_link = null,
      token = '';

delete from delayed_jobs;
delete from payment_transactions;
delete from shortened_urls;
delete from stripe_events;