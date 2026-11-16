-- =============================================================================
-- BLUE HOUR HQ – COMPLETE NORMALIZED POSTGRESQL DATABASE SCHEMA
-- Organization: Blue Hour Creative Studios
-- Database: PostgreSQL 15+ (UUID, TIMESTAMPTZ, JSONB, Soft Deletes, Indexes)
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- -----------------------------------------------------------------------------
-- 1. USER MANAGEMENT & RBAC
-- -----------------------------------------------------------------------------

CREATE TABLE departments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(30) NOT NULL UNIQUE,
    description TEXT,
    head_user_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(180) NOT NULL UNIQUE,
    phone VARCHAR(30),
    password_hash VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
    designation VARCHAR(120) NOT NULL,
    joining_date DATE,
    status VARCHAR(30) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'on_leave', 'suspended', 'inactive')),
    two_factor_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    two_factor_secret TEXT,
    founder_briefing_time TIME NOT NULL DEFAULT '08:30:00',
    timezone VARCHAR(64) NOT NULL DEFAULT 'Asia/Kolkata',
    last_seen_at TIMESTAMPTZ,
    is_online BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

ALTER TABLE departments
    ADD CONSTRAINT fk_departments_head_user
    FOREIGN KEY (head_user_id) REFERENCES users(id) ON DELETE SET NULL;

CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(60) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_system_role BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module VARCHAR(60) NOT NULL,
    action VARCHAR(60) NOT NULL,
    slug VARCHAR(120) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE role_permissions (
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    granted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE user_roles (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_by UUID REFERENCES users(id) ON DELETE SET NULL,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, role_id)
);

-- -----------------------------------------------------------------------------
-- 2. CRM & LEAD MANAGEMENT
-- -----------------------------------------------------------------------------

CREATE TABLE lead_sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(80) NOT NULL UNIQUE,
    slug VARCHAR(80) NOT NULL UNIQUE,
    icon_name VARCHAR(60),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE leads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lead_code VARCHAR(30) NOT NULL UNIQUE,
    company_name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(150) NOT NULL,
    phone VARCHAR(35) NOT NULL,
    email VARCHAR(180),
    website VARCHAR(255),
    location VARCHAR(150),
    industry VARCHAR(120),
    lead_source_id UUID REFERENCES lead_sources(id) ON DELETE SET NULL,
    interested_service VARCHAR(120) NOT NULL,
    estimated_budget_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    assigned_to UUID REFERENCES users(id) ON DELETE SET NULL,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    priority VARCHAR(20) NOT NULL DEFAULT 'High' CHECK (priority IN ('Low', 'Medium', 'High', 'Urgent')),
    status VARCHAR(40) NOT NULL DEFAULT 'New Lead' CHECK (
        status IN (
            'New Lead', 'Contacted', 'Meeting Scheduled', 'Requirement Gathering',
            'Proposal Sent', 'Negotiation', 'Converted', 'Lost'
        )
    ),
    expected_closing_date DATE,
    lost_reason TEXT,
    converted_client_id UUID,
    converted_at TIMESTAMPTZ,
    notes TEXT,
    last_contacted_at TIMESTAMPTZ,
    next_followup_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_leads_status_priority ON leads(status, priority) WHERE deleted_at IS NULL;
CREATE INDEX idx_leads_assigned_to ON leads(assigned_to) WHERE deleted_at IS NULL;
CREATE INDEX idx_leads_next_followup ON leads(next_followup_at) WHERE deleted_at IS NULL;

CREATE TABLE lead_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lead_id UUID NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
    actor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    activity_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    metadata_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE lead_followups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lead_id UUID NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
    assigned_to UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    followup_type VARCHAR(40) NOT NULL CHECK (
        followup_type IN ('Phone Call', 'WhatsApp', 'Email', 'Client Meeting', 'General Follow-up')
    ),
    scheduled_at TIMESTAMPTZ NOT NULL,
    notes TEXT,
    reminder_preferences_json JSONB NOT NULL DEFAULT '["1d","1h","15m","0m"]'::jsonb,
    status VARCHAR(30) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'rescheduled', 'overdue', 'cancelled')),
    completed_at TIMESTAMPTZ,
    outcome_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE lead_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lead_id UUID NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
    from_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    to_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    assigned_by UUID REFERENCES users(id) ON DELETE SET NULL,
    reason TEXT,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 3. CLIENT MANAGEMENT
-- -----------------------------------------------------------------------------

CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_code VARCHAR(30) NOT NULL UNIQUE,
    lead_id UUID REFERENCES leads(id) ON DELETE SET NULL,
    company_name VARCHAR(200) NOT NULL,
    primary_contact_name VARCHAR(150) NOT NULL,
    email VARCHAR(180) NOT NULL,
    phone VARCHAR(35) NOT NULL,
    website VARCHAR(255),
    billing_address TEXT,
    gstin VARCHAR(30),
    industry VARCHAR(120),
    services_purchased_json JSONB NOT NULL DEFAULT '[]'::jsonb,
    account_manager_id UUID REFERENCES users(id) ON DELETE SET NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'retainer', 'on_hold', 'completed', 'inactive')),
    lifetime_value_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    outstanding_balance_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    notes TEXT,
    onboarded_at DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE client_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    designation VARCHAR(100),
    email VARCHAR(180),
    phone VARCHAR(35),
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 4. PROJECT & TASK MANAGEMENT
-- -----------------------------------------------------------------------------

CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
    category VARCHAR(80) NOT NULL CHECK (
        category IN (
            'Website Development', 'E-commerce Development', 'Web Applications',
            'UI/UX Design', 'Social Media Management', 'Digital Marketing',
            'Custom Software Development', 'Branding & Creative'
        )
    ),
    description TEXT,
    project_manager_id UUID REFERENCES users(id) ON DELETE SET NULL,
    start_date DATE NOT NULL,
    deadline DATE NOT NULL,
    budget_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'In Progress' CHECK (
        status IN ('Planning', 'In Progress', 'In Review', 'On Hold', 'Completed', 'Delayed')
    ),
    progress_percentage SMALLINT NOT NULL DEFAULT 0 CHECK (progress_percentage BETWEEN 0 AND 100),
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE project_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_in_project VARCHAR(80) NOT NULL,
    allocated_hours NUMERIC(7, 2) DEFAULT 0,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (project_id, user_id)
);

CREATE TABLE project_milestones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    title VARCHAR(180) NOT NULL,
    description TEXT,
    due_date DATE NOT NULL,
    amount_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'overdue')),
    completed_at TIMESTAMPTZ,
    sort_order SMALLINT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_code VARCHAR(30) NOT NULL UNIQUE,
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    milestone_id UUID REFERENCES project_milestones(id) ON DELETE SET NULL,
    title VARCHAR(220) NOT NULL,
    description TEXT,
    assigned_to UUID REFERENCES users(id) ON DELETE SET NULL,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    priority VARCHAR(20) NOT NULL DEFAULT 'Medium' CHECK (priority IN ('Low', 'Medium', 'High', 'Critical')),
    status VARCHAR(30) NOT NULL DEFAULT 'To Do' CHECK (
        status IN ('To Do', 'In Progress', 'Review', 'Completed', 'Blocked')
    ),
    start_date DATE,
    deadline TIMESTAMPTZ NOT NULL,
    estimated_hours NUMERIC(6, 2) DEFAULT 0,
    logged_hours NUMERIC(6, 2) DEFAULT 0,
    is_recurring BOOLEAN NOT NULL DEFAULT FALSE,
    recurrence_rule VARCHAR(120),
    depends_on_task_id UUID REFERENCES tasks(id) ON DELETE SET NULL,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE subtasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    assigned_to UUID REFERENCES users(id) ON DELETE SET NULL,
    completed_at TIMESTAMPTZ,
    sort_order SMALLINT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE task_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    body TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE task_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    uploaded_by UUID REFERENCES users(id) ON DELETE SET NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path TEXT NOT NULL,
    mime_type VARCHAR(100),
    file_size_bytes BIGINT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 5. INTERNAL REAL-TIME CHAT (REVERB WEBSOCKETS)
-- -----------------------------------------------------------------------------

CREATE TABLE channels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(80) NOT NULL UNIQUE,
    name VARCHAR(120) NOT NULL,
    description TEXT,
    channel_type VARCHAR(30) NOT NULL DEFAULT 'department' CHECK (
        channel_type IN ('general', 'department', 'project', 'announcement', 'private')
    ),
    department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    is_private BOOLEAN NOT NULL DEFAULT FALSE,
    is_announcement_only BOOLEAN NOT NULL DEFAULT FALSE,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE channel_members (
    channel_id UUID NOT NULL REFERENCES channels(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'member')),
    is_muted BOOLEAN NOT NULL DEFAULT FALSE,
    last_read_message_id UUID,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (channel_id, user_id)
);

CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_type VARCHAR(20) NOT NULL CHECK (conversation_type IN ('direct', 'group', 'channel')),
    title VARCHAR(150),
    channel_id UUID REFERENCES channels(id) ON DELETE CASCADE,
    last_message_id UUID,
    last_message_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE conversation_members (
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    is_pinned BOOLEAN NOT NULL DEFAULT FALSE,
    is_muted BOOLEAN NOT NULL DEFAULT FALSE,
    unread_count INTEGER NOT NULL DEFAULT 0,
    last_read_at TIMESTAMPTZ,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (conversation_id, user_id)
);

CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reply_to_message_id UUID REFERENCES messages(id) ON DELETE SET NULL,
    message_type VARCHAR(30) NOT NULL DEFAULT 'text' CHECK (
        message_type IN ('text', 'image', 'document', 'voice', 'announcement', 'system')
    ),
    body TEXT,
    voice_duration_sec SMALLINT,
    is_pinned BOOLEAN NOT NULL DEFAULT FALSE,
    is_edited BOOLEAN NOT NULL DEFAULT FALSE,
    edited_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_messages_conversation_created ON messages(conversation_id, created_at DESC);

CREATE TABLE message_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    storage_path TEXT NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    file_size_bytes BIGINT NOT NULL DEFAULT 0,
    thumbnail_path TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE message_reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    emoji VARCHAR(24) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (message_id, user_id, emoji)
);

CREATE TABLE message_reads (
    message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    read_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (message_id, user_id)
);

-- -----------------------------------------------------------------------------
-- 6. MEETINGS & CALENDAR
-- -----------------------------------------------------------------------------

CREATE TABLE meetings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meeting_code VARCHAR(30) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    meeting_type VARCHAR(40) NOT NULL CHECK (
        meeting_type IN (
            'Client Meeting', 'Sales Meeting', 'Internal Meeting',
            'Project Discussion', 'Review Meeting', 'Founder Meeting'
        )
    ),
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    lead_id UUID REFERENCES leads(id) ON DELETE SET NULL,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    organizer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    meeting_date DATE NOT NULL,
    start_time_utc TIMESTAMPTZ NOT NULL,
    end_time_utc TIMESTAMPTZ NOT NULL,
    location VARCHAR(255),
    online_meeting_link TEXT,
    status VARCHAR(30) NOT NULL DEFAULT 'Scheduled' CHECK (
        status IN ('Scheduled', 'In Progress', 'Completed', 'Rescheduled', 'Cancelled')
    ),
    reminder_intervals_json JSONB NOT NULL DEFAULT '["1d","1h","15m","0m"]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE meeting_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meeting_id UUID NOT NULL REFERENCES meetings(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    external_email VARCHAR(180),
    attendance_status VARCHAR(25) NOT NULL DEFAULT 'invited' CHECK (
        attendance_status IN ('invited', 'accepted', 'declined', 'attended')
    ),
    notified_at TIMESTAMPTZ
);

CREATE TABLE meeting_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meeting_id UUID NOT NULL REFERENCES meetings(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    action_items_json JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 7. NOTIFICATIONS & AUTOMATED REMINDER ENGINE
-- -----------------------------------------------------------------------------

CREATE TABLE device_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id VARCHAR(150) NOT NULL,
    platform VARCHAR(20) NOT NULL CHECK (platform IN ('android', 'ios')),
    fcm_token TEXT NOT NULL,
    device_model VARCHAR(120),
    app_version VARCHAR(30),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, device_id)
);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category VARCHAR(30) NOT NULL CHECK (
        category IN ('Leads', 'Meetings', 'Tasks', 'Projects', 'Messages', 'Payments', 'Announcements')
    ),
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    deep_link_route VARCHAR(255),
    entity_type VARCHAR(60),
    entity_id UUID,
    action_buttons_json JSONB NOT NULL DEFAULT '[]'::jsonb,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_read, created_at DESC);

CREATE TABLE notification_preferences (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    lead_reminders BOOLEAN NOT NULL DEFAULT TRUE,
    meeting_reminders BOOLEAN NOT NULL DEFAULT TRUE,
    task_reminders BOOLEAN NOT NULL DEFAULT TRUE,
    project_updates BOOLEAN NOT NULL DEFAULT TRUE,
    chat_messages BOOLEAN NOT NULL DEFAULT TRUE,
    payment_alerts BOOLEAN NOT NULL DEFAULT TRUE,
    daily_summary BOOLEAN NOT NULL DEFAULT TRUE,
    quiet_hours_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    quiet_hours_start TIME NOT NULL DEFAULT '22:30:00',
    quiet_hours_end TIME NOT NULL DEFAULT '07:30:00',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE scheduled_reminders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    idempotency_key VARCHAR(180) NOT NULL UNIQUE,
    target_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reminder_category VARCHAR(40) NOT NULL CHECK (
        reminder_category IN ('lead_followup', 'meeting', 'task_deadline', 'payment_due', 'founder_briefing')
    ),
    source_type VARCHAR(50) NOT NULL,
    source_id UUID NOT NULL,
    offset_label VARCHAR(30) NOT NULL,
    scheduled_for_utc TIMESTAMPTZ NOT NULL,
    payload_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    status VARCHAR(25) NOT NULL DEFAULT 'queued' CHECK (
        status IN ('queued', 'processing', 'dispatched', 'cancelled', 'failed')
    ),
    processed_at TIMESTAMPTZ,
    retry_count SMALLINT NOT NULL DEFAULT 0,
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_scheduled_reminders_due ON scheduled_reminders(status, scheduled_for_utc)
    WHERE status = 'queued';

CREATE TABLE notification_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id UUID REFERENCES notifications(id) ON DELETE SET NULL,
    scheduled_reminder_id UUID REFERENCES scheduled_reminders(id) ON DELETE SET NULL,
    device_token_id UUID REFERENCES device_tokens(id) ON DELETE SET NULL,
    fcm_message_id VARCHAR(180),
    delivery_status VARCHAR(30) NOT NULL CHECK (delivery_status IN ('sent', 'delivered', 'failed', 'invalid_token')),
    response_payload JSONB,
    sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 8. PROPOSALS & FINANCE MANAGEMENT (INR)
-- -----------------------------------------------------------------------------

CREATE TABLE proposals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    proposal_code VARCHAR(30) NOT NULL UNIQUE,
    lead_id UUID REFERENCES leads(id) ON DELETE SET NULL,
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    title VARCHAR(200) NOT NULL,
    template_name VARCHAR(100),
    services_summary TEXT,
    subtotal_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    discount_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    tax_percent NUMERIC(5, 2) NOT NULL DEFAULT 18.00,
    tax_amount_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    total_amount_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    valid_until DATE NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Draft' CHECK (
        status IN ('Draft', 'Sent', 'Under Review', 'Accepted', 'Rejected', 'Expired')
    ),
    terms_and_conditions TEXT,
    pdf_storage_path TEXT,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    sent_at TIMESTAMPTZ,
    responded_at TIMESTAMPTZ,
    rejection_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE proposal_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
    service_category VARCHAR(100) NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    quantity NUMERIC(8, 2) NOT NULL DEFAULT 1,
    unit_price_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    line_total_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    sort_order SMALLINT NOT NULL DEFAULT 0
);

CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_number VARCHAR(40) NOT NULL UNIQUE,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    proposal_id UUID REFERENCES proposals(id) ON DELETE SET NULL,
    issue_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    subtotal_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    discount_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    cgst_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    sgst_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    igst_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    total_amount_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    amount_paid_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    balance_due_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'Unpaid' CHECK (
        status IN ('Draft', 'Sent', 'Partially Paid', 'Paid', 'Overdue', 'Cancelled')
    ),
    notes TEXT,
    pdf_storage_path TEXT,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE invoice_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    description VARCHAR(255) NOT NULL,
    service_category VARCHAR(100),
    quantity NUMERIC(8, 2) NOT NULL DEFAULT 1,
    unit_price_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    total_inr NUMERIC(14, 2) NOT NULL DEFAULT 0,
    sort_order SMALLINT NOT NULL DEFAULT 0
);

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_code VARCHAR(30) NOT NULL UNIQUE,
    invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE RESTRICT,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
    amount_inr NUMERIC(14, 2) NOT NULL,
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    payment_method VARCHAR(40) NOT NULL CHECK (
        payment_method IN ('NEFT/RTGS', 'UPI', 'IMPS', 'Wire Transfer', 'Card', 'Cheque')
    ),
    transaction_reference VARCHAR(120),
    is_advance BOOLEAN NOT NULL DEFAULT FALSE,
    recorded_by UUID REFERENCES users(id) ON DELETE SET NULL,
    notes TEXT,
    receipt_path TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    expense_code VARCHAR(30) NOT NULL UNIQUE,
    category VARCHAR(80) NOT NULL,
    vendor_name VARCHAR(150) NOT NULL,
    description TEXT,
    amount_inr NUMERIC(14, 2) NOT NULL,
    expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    submitted_by UUID REFERENCES users(id) ON DELETE SET NULL,
    approved_by UUID REFERENCES users(id) ON DELETE SET NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Approved' CHECK (status IN ('Pending', 'Approved', 'Rejected', 'Reimbursed')),
    receipt_path TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 9. DOCUMENTS & SYSTEM GOVERNANCE
-- -----------------------------------------------------------------------------

CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    category VARCHAR(60) NOT NULL,
    entity_type VARCHAR(60),
    entity_id UUID,
    storage_disk VARCHAR(30) NOT NULL DEFAULT 's3',
    storage_path TEXT NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    file_size_bytes BIGINT NOT NULL DEFAULT 0,
    uploaded_by UUID REFERENCES users(id) ON DELETE SET NULL,
    is_confidential BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE document_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    role_id UUID REFERENCES roles(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    can_view BOOLEAN NOT NULL DEFAULT TRUE,
    can_download BOOLEAN NOT NULL DEFAULT TRUE,
    can_delete BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    module VARCHAR(60) NOT NULL,
    action VARCHAR(80) NOT NULL,
    entity_type VARCHAR(60),
    entity_id UUID,
    summary TEXT NOT NULL,
    ip_address VARCHAR(45),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    sanctum_token_id BIGINT,
    device_name VARCHAR(150) NOT NULL,
    platform VARCHAR(30) NOT NULL,
    ip_address VARCHAR(45),
    last_active_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    event_type VARCHAR(80) NOT NULL,
    auditable_type VARCHAR(80) NOT NULL,
    auditable_id UUID,
    old_values_json JSONB,
    new_values_json JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

