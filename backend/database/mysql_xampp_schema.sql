-- ============================================================================
-- BLUE HOUR HQ — LIVE XAMPP MYSQL / MARIADB SCHEMA (blue_hour_hq)
-- Studio: Blue Hour Creative Studios (https://theblue-hour-studios.vercel.app/)
-- Founders: Himon Bhuyan, Darshana Das, Drishant Das
-- ============================================================================

CREATE DATABASE IF NOT EXISTS `blue_hour_hq`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `blue_hour_hq`;

-- 1. Founders / Studio Leadership Table
CREATE TABLE IF NOT EXISTS `founders` (
  `id` VARCHAR(64) NOT NULL PRIMARY KEY,
  `employee_code` VARCHAR(32) NOT NULL UNIQUE,
  `name` VARCHAR(120) NOT NULL,
  `email` VARCHAR(160) NOT NULL UNIQUE,
  `phone` VARCHAR(40) NOT NULL,
  `role` VARCHAR(40) NOT NULL DEFAULT 'founder',
  `department` VARCHAR(160) NOT NULL,
  `designation` VARCHAR(160) NOT NULL,
  `is_online` TINYINT(1) NOT NULL DEFAULT 1,
  `two_factor_enabled` TINYINT(1) NOT NULL DEFAULT 1,
  `briefing_time` VARCHAR(32) NOT NULL DEFAULT '08:30 AM',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `founders` (`id`, `employee_code`, `name`, `email`, `phone`, `role`, `department`, `designation`, `is_online`, `two_factor_enabled`, `briefing_time`)
VALUES
  ('emp-01', 'BH-001', 'Himon Bhuyan', 'himonbhuyan@gmail.com', '+91 70022 01534', 'superAdmin', 'Software Architecture, SaaS & AI', 'Founder & Principal Software Architect', 1, 1, '08:30 AM'),
  ('emp-02', 'BH-002', 'Darshana Das', 'darshana@bluehourstudios.in', '+91 84738 91457', 'founder', 'Client Growth, Branding & Social Strategy', 'Partner — Head of Client Growth & Social Media Strategy', 1, 1, '08:30 AM'),
  ('emp-03', 'BH-003', 'Drishant Das', 'drishant@bluehourstudios.in', '+91 70028 45190', 'founder', 'Hardware Engineering, Embedded & IoT Systems', 'Co-Founder — Principal Hardware & IoT Architect', 1, 1, '08:30 AM')
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `email` = VALUES(`email`),
  `phone` = VALUES(`phone`),
  `role` = VALUES(`role`),
  `department` = VALUES(`department`),
  `designation` = VALUES(`designation`);

-- 2. CRM Leads Table
CREATE TABLE IF NOT EXISTS `leads` (
  `id` VARCHAR(64) NOT NULL PRIMARY KEY,
  `lead_code` VARCHAR(32) NOT NULL,
  `company_name` VARCHAR(180) NOT NULL,
  `contact_person` VARCHAR(140) NOT NULL,
  `phone` VARCHAR(40) NOT NULL,
  `email` VARCHAR(160) NOT NULL DEFAULT '',
  `website` VARCHAR(255) NOT NULL DEFAULT '',
  `location` VARCHAR(140) NOT NULL DEFAULT 'Guwahati, Assam',
  `industry` VARCHAR(140) NOT NULL DEFAULT 'Technology & Digital',
  `source` VARCHAR(80) NOT NULL,
  `interested_service` VARCHAR(160) NOT NULL,
  `estimated_budget_inr` DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `assigned_employee_name` VARCHAR(120) NOT NULL,
  `priority` VARCHAR(32) NOT NULL DEFAULT 'High',
  `status` VARCHAR(64) NOT NULL DEFAULT 'New Lead',
  `expected_closing_date` DATETIME NOT NULL,
  `created_date` DATETIME NOT NULL,
  `next_followup_at` DATETIME NULL,
  `notes` TEXT NULL,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Lead Follow-ups Table
CREATE TABLE IF NOT EXISTS `lead_followups` (
  `id` VARCHAR(64) NOT NULL PRIMARY KEY,
  `lead_id` VARCHAR(64) NOT NULL,
  `company_name` VARCHAR(180) NOT NULL,
  `assigned_employee` VARCHAR(120) NOT NULL,
  `followup_type` VARCHAR(80) NOT NULL,
  `scheduled_at` DATETIME NOT NULL,
  `notes` TEXT NULL,
  `is_completed` TINYINT(1) NOT NULL DEFAULT 0,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Clients Table
CREATE TABLE IF NOT EXISTS `clients` (
  `id` VARCHAR(64) NOT NULL PRIMARY KEY,
  `client_code` VARCHAR(32) NOT NULL,
  `company_name` VARCHAR(180) NOT NULL,
  `contact_person` VARCHAR(140) NOT NULL,
  `email` VARCHAR(160) NOT NULL DEFAULT '',
  `phone` VARCHAR(40) NOT NULL DEFAULT '',
  `website` VARCHAR(255) NOT NULL DEFAULT '',
  `address` VARCHAR(255) NOT NULL DEFAULT '',
  `industry` VARCHAR(140) NOT NULL DEFAULT '',
  `services_purchased_json` JSON NOT NULL,
  `account_manager` VARCHAR(120) NOT NULL,
  `status` VARCHAR(40) NOT NULL DEFAULT 'Active',
  `total_billed_inr` DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `outstanding_inr` DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `active_projects_count` INT NOT NULL DEFAULT 1,
  `onboarded_at` DATETIME NOT NULL,
  `notes` TEXT NULL,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Projects Table
CREATE TABLE IF NOT EXISTS `projects` (
  `id` VARCHAR(64) NOT NULL PRIMARY KEY,
  `project_code` VARCHAR(32) NOT NULL,
  `name` VARCHAR(180) NOT NULL,
  `client_name` VARCHAR(180) NOT NULL,
  `category` VARCHAR(120) NOT NULL,
  `description` TEXT NULL,
  `project_manager` VARCHAR(120) NOT NULL,
  `assigned_team_json` JSON NOT NULL,
  `start_date` DATETIME NOT NULL,
  `deadline` DATETIME NOT NULL,
  `budget_inr` DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `status` VARCHAR(40) NOT NULL DEFAULT 'In Progress',
  `progress_percentage` INT NOT NULL DEFAULT 0,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Tasks Table
CREATE TABLE IF NOT EXISTS `tasks` (
  `id` VARCHAR(64) NOT NULL PRIMARY KEY,
  `task_code` VARCHAR(32) NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `description` TEXT NULL,
  `project_id` VARCHAR(64) NOT NULL,
  `project_name` VARCHAR(180) NOT NULL,
  `assigned_employee` VARCHAR(120) NOT NULL,
  `priority` VARCHAR(32) NOT NULL DEFAULT 'High',
  `status` VARCHAR(40) NOT NULL DEFAULT 'To Do',
  `start_date` DATETIME NOT NULL,
  `deadline` DATETIME NOT NULL,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Meetings Table
CREATE TABLE IF NOT EXISTS `meetings` (
  `id` VARCHAR(64) NOT NULL PRIMARY KEY,
  `meeting_code` VARCHAR(32) NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `client_or_company` VARCHAR(180) NOT NULL,
  `description` TEXT NULL,
  `start_time` DATETIME NOT NULL,
  `end_time` DATETIME NOT NULL,
  `meeting_type` VARCHAR(80) NOT NULL,
  `location` VARCHAR(180) NOT NULL,
  `online_meeting_link` VARCHAR(255) NULL,
  `participants_json` JSON NOT NULL,
  `assigned_employee` VARCHAR(120) NOT NULL,
  `notes` TEXT NULL,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Commercial Proposals Table (INR + 18% GST)
CREATE TABLE IF NOT EXISTS `proposals` (
  `id` VARCHAR(64) NOT NULL PRIMARY KEY,
  `proposal_code` VARCHAR(32) NOT NULL,
  `client_or_lead_name` VARCHAR(180) NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `service_category` VARCHAR(140) NOT NULL,
  `subtotal_inr` DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `discount_inr` DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `gst_amount_inr` DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `total_amount_inr` DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `valid_until` DATETIME NOT NULL,
  `status` VARCHAR(40) NOT NULL DEFAULT 'Sent',
  `prepared_by` VARCHAR(120) NOT NULL,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. GST Invoices Table (INR)
CREATE TABLE IF NOT EXISTS `invoices` (
  `id` VARCHAR(64) NOT NULL PRIMARY KEY,
  `invoice_number` VARCHAR(32) NOT NULL,
  `client_name` VARCHAR(180) NOT NULL,
  `project_name` VARCHAR(180) NOT NULL,
  `service_category` VARCHAR(140) NOT NULL,
  `issue_date` DATETIME NOT NULL,
  `due_date` DATETIME NOT NULL,
  `total_amount_inr` DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `paid_amount_inr` DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `status` VARCHAR(40) NOT NULL DEFAULT 'Sent',
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. Studio Expenses Table (INR)
CREATE TABLE IF NOT EXISTS `expenses` (
  `id` VARCHAR(64) NOT NULL PRIMARY KEY,
  `expense_code` VARCHAR(32) NOT NULL,
  `category` VARCHAR(120) NOT NULL,
  `vendor_name` VARCHAR(180) NOT NULL,
  `description` TEXT NULL,
  `amount_inr` DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `expense_date` DATETIME NOT NULL,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. Notifications Table
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` VARCHAR(64) NOT NULL PRIMARY KEY,
  `category` VARCHAR(64) NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `body` TEXT NOT NULL,
  `timestamp` DATETIME NOT NULL,
  `is_read` TINYINT(1) NOT NULL DEFAULT 0,
  `target_route` VARCHAR(120) NULL,
  `entity_id` VARCHAR(64) NULL,
  `actions_json` JSON NOT NULL,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. Founders Chat Threads Table
CREATE TABLE IF NOT EXISTS `chat_threads` (
  `id` VARCHAR(64) NOT NULL PRIMARY KEY,
  `name` VARCHAR(140) NOT NULL,
  `subtitle` VARCHAR(220) NOT NULL,
  `is_channel` TINYINT(1) NOT NULL DEFAULT 0,
  `is_private` TINYINT(1) NOT NULL DEFAULT 1,
  `unread_count` INT NOT NULL DEFAULT 0,
  `members_count` INT NOT NULL DEFAULT 2,
  `last_message_preview` VARCHAR(255) NOT NULL DEFAULT 'No messages yet',
  `last_activity` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `chat_threads` (`id`, `name`, `subtitle`, `is_channel`, `is_private`, `unread_count`, `members_count`, `last_message_preview`)
VALUES
  ('founders-hq', 'Founders Board', 'Himon Bhuyan • Darshana Das • Drishant Das', 1, 1, 0, 3, 'No messages yet'),
  ('dm-darshana', 'Darshana Das', 'Partner — Head of Client Growth & Social Media Strategy', 0, 1, 0, 2, 'No messages yet'),
  ('dm-drishant', 'Drishant Das', 'Co-Founder — Principal Hardware & IoT Architect', 0, 1, 0, 2, 'No messages yet'),
  ('dm-himon', 'Himon Bhuyan', 'Founder & Principal Software Architect', 0, 1, 0, 2, 'No messages yet')
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `subtitle` = VALUES(`subtitle`);

-- 13. Founders Chat Messages Table
CREATE TABLE IF NOT EXISTS `chat_messages` (
  `id` VARCHAR(80) NOT NULL,
  `thread_id` VARCHAR(64) NOT NULL,
  `sender_id` VARCHAR(64) NOT NULL,
  `sender_name` VARCHAR(120) NOT NULL,
  `sender_role` VARCHAR(160) NOT NULL,
  `body` TEXT NOT NULL,
  `timestamp` DATETIME NOT NULL,
  `message_type` VARCHAR(32) NOT NULL DEFAULT 'text',
  `attachment_name` VARCHAR(255) NULL,
  `attachment_size` VARCHAR(64) NULL,
  `voice_duration_sec` INT NULL,
  `reply_to_sender` VARCHAR(120) NULL,
  `reply_to_preview` TEXT NULL,
  `reactions_json` JSON NOT NULL,
  `is_pinned` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`, `thread_id`),
  INDEX `idx_thread_timestamp` (`thread_id`, `timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

