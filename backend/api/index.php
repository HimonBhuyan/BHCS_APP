<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

$dsn = 'mysql:host=127.0.0.1;dbname=blue_hour_hq;charset=utf8mb4';
$dbUser = 'root';
$dbPass = '';

try {
    $pdo = new PDO($dsn, $dbUser, $dbPass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'ok' => false,
        'error' => 'Database connection failed: ' . $e->getMessage(),
    ]);
    exit;
}

function toMysqlDateTime(?string $iso): ?string {
    if ($iso === null || trim($iso) === '') {
        return null;
    }
    $ts = strtotime($iso);
    if ($ts === false) {
        return date('Y-m-d H:i:s');
    }
    return date('Y-m-d H:i:s', $ts);
}

function toIso8601(?string $mysqlDt): ?string {
    if ($mysqlDt === null || trim($mysqlDt) === '') {
        return null;
    }
    $ts = strtotime($mysqlDt);
    if ($ts === false) {
        return date('c');
    }
    return date('Y-m-d\TH:i:s.000', $ts);
}

function base64UrlEncode(string $data): string {
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

function getFcmAccessToken(?string &$errorOut = null): ?array {
    $saPath = __DIR__ . '/firebase-service-account.json';
    if (!file_exists($saPath)) {
        $errorOut = 'Missing firebase-service-account.json';
        return null;
    }
    $sa = json_decode((string) file_get_contents($saPath), true);
    if (!is_array($sa) || empty($sa['private_key']) || empty($sa['client_email']) || empty($sa['project_id'])) {
        $errorOut = 'Invalid service account JSON';
        return null;
    }

    $cachePath = sys_get_temp_dir() . '/bh_fcm_oauth_cache.json';
    if (file_exists($cachePath)) {
        $cached = json_decode((string) file_get_contents($cachePath), true);
        if (is_array($cached) && !empty($cached['access_token']) && ($cached['expires_at'] ?? 0) > time() + 60) {
            return ['token' => $cached['access_token'], 'project_id' => $sa['project_id']];
        }
    }

    $now = time();
    $header = base64UrlEncode((string) json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
    $claims = base64UrlEncode((string) json_encode([
        'iss' => $sa['client_email'],
        'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
        'aud' => $sa['token_uri'] ?? 'https://oauth2.googleapis.com/token',
        'iat' => $now,
        'exp' => $now + 3600,
    ]));

    $signingInput = $header . '.' . $claims;
    $signature = '';
    if (!openssl_sign($signingInput, $signature, $sa['private_key'], OPENSSL_ALGO_SHA256)) {
        $errorOut = 'OpenSSL signing failed';
        return null;
    }
    $jwt = $signingInput . '.' . base64UrlEncode($signature);

    $ch = curl_init($sa['token_uri'] ?? 'https://oauth2.googleapis.com/token');
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => http_build_query([
            'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            'assertion' => $jwt,
        ]),
        CURLOPT_HTTPHEADER => ['Content-Type: application/x-www-form-urlencoded'],
        CURLOPT_TIMEOUT => 10,
    ]);
    $rawResp = curl_exec($ch);
    $curlErr = curl_error($ch);
    $status = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($rawResp === false || $status !== 200) {
        // Fallback retry if local Windows PHP lacks CA bundle path
        $ch2 = curl_init($sa['token_uri'] ?? 'https://oauth2.googleapis.com/token');
        curl_setopt_array($ch2, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => http_build_query([
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt,
            ]),
            CURLOPT_HTTPHEADER => ['Content-Type: application/x-www-form-urlencoded'],
            CURLOPT_SSL_VERIFYPEER => false,
            CURLOPT_TIMEOUT => 10,
        ]);
        $rawResp = curl_exec($ch2);
        $curlErr = curl_error($ch2);
        $status = (int) curl_getinfo($ch2, CURLINFO_HTTP_CODE);
        curl_close($ch2);
    }

    $decoded = json_decode((string) $rawResp, true);
    if (!is_array($decoded) || empty($decoded['access_token'])) {
        $errorOut = "OAuth failed ($status): " . ($curlErr ?: (string) $rawResp);
        return null;
    }

    @file_put_contents($cachePath, json_encode([
        'access_token' => $decoded['access_token'],
        'expires_at' => $now + (int) ($decoded['expires_in'] ?? 3500),
    ]));

    return ['token' => $decoded['access_token'], 'project_id' => $sa['project_id']];
}

function sendFcmPushToTopic(string $topic, string $title, string $body, string $category = 'Messages', string $targetRoute = '/chat'): array {
    $err = null;
    $auth = getFcmAccessToken($err);
    if ($auth === null) {
        return ['ok' => false, 'topic' => $topic, 'error' => $err];
    }

    $channelId = match ($category) {
        'Messages' => 'blue_hour_hq_messages',
        'Meetings' => 'blue_hour_hq_meetings',
        'Leads' => 'blue_hour_hq_leads',
        default => 'blue_hour_hq_high',
    };

    $messagePayload = [
        'message' => [
            'topic' => $topic,
            'notification' => [
                'title' => $title,
                'body' => $body,
            ],
            'data' => [
                'title' => $title,
                'body' => $body,
                'category' => $category,
                'targetRoute' => $targetRoute,
                'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
            ],
            'android' => [
                'priority' => 'HIGH',
                'ttl' => '86400s',
                'notification' => [
                    'channel_id' => $channelId,
                    'sound' => 'default',
                    'default_sound' => true,
                    'default_vibrate_timings' => true,
                    'visibility' => 'PUBLIC',
                    'notification_priority' => 'PRIORITY_MAX',
                ],
            ],
            'apns' => [
                'headers' => [
                    'apns-priority' => '10',
                ],
                'payload' => [
                    'aps' => [
                        'sound' => 'default',
                        'content-available' => 1,
                    ],
                ],
            ],
        ],
    ];

    $url = "https://fcm.googleapis.com/v1/projects/{$auth['project_id']}/messages:send";
    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => json_encode($messagePayload),
        CURLOPT_HTTPHEADER => [
            'Authorization: Bearer ' . $auth['token'],
            'Content-Type: application/json',
        ],
        CURLOPT_SSL_VERIFYPEER => false,
        CURLOPT_TIMEOUT => 10,
    ]);
    $raw = curl_exec($ch);
    $status = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $curlErr = curl_error($ch);
    curl_close($ch);

    return [
        'ok' => $status >= 200 && $status < 300,
        'status' => $status,
        'topic' => $topic,
        'response' => json_decode((string) $raw, true) ?: (string) $raw,
        'curl_error' => $curlErr ?: null,
    ];
}

$action = $_GET['action'] ?? ($_SERVER['REQUEST_METHOD'] === 'POST' ? 'sync' : 'pull');

if ($action === 'health') {
    $counts = [];
    foreach (['founders', 'leads', 'clients', 'projects', 'tasks', 'meetings', 'proposals', 'invoices', 'expenses', 'notifications', 'chat_threads', 'chat_messages'] as $tbl) {
        $counts[$tbl] = (int) $pdo->query("SELECT COUNT(*) FROM `$tbl`")->fetchColumn();
    }
    echo json_encode([
        'ok' => true,
        'database' => 'blue_hour_hq',
        'engine' => 'MySQL/MariaDB (XAMPP Live)',
        'fcm_configured' => file_exists(__DIR__ . '/firebase-service-account.json'),
        'counts' => $counts,
        'timestamp' => date('c'),
    ]);
    exit;
}

if ($action === 'upload_media' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $raw = file_get_contents('php://input');
    $data = json_decode($raw ?: '{}', true);
    $b64 = is_array($data) ? (string) ($data['base64'] ?? '') : '';
    $origName = is_array($data) ? (string) ($data['fileName'] ?? 'file.bin') : 'file.bin';
    if ($b64 === '') {
        http_response_code(400);
        echo json_encode(['ok' => false, 'error' => 'Missing base64 payload']);
        exit;
    }
    $bytes = base64_decode($b64, true);
    if ($bytes === false || strlen($bytes) > 15 * 1024 * 1024) {
        http_response_code(400);
        echo json_encode(['ok' => false, 'error' => 'Invalid or oversized upload (max 15MB)']);
        exit;
    }
    $uploadDir = dirname(__DIR__) . '/uploads';
    if (!is_dir($uploadDir)) {
        @mkdir($uploadDir, 0775, true);
    }
    $ext = strtolower(pathinfo($origName, PATHINFO_EXTENSION));
    $safeExt = preg_replace('/[^a-z0-9]/', '', $ext) ?: 'bin';
    $storedName = 'bh_' . date('Ymd_His') . '_' . bin2hex(random_bytes(4)) . '.' . $safeExt;
    file_put_contents($uploadDir . '/' . $storedName, $bytes);
    echo json_encode([
        'ok' => true,
        'fileName' => $storedName,
        'sizeBytes' => strlen($bytes),
    ]);
    exit;
}

if ($action === 'media') {
    $file = basename((string) ($_GET['file'] ?? ''));
    $path = dirname(__DIR__) . '/uploads/' . $file;
    if ($file === '' || !is_file($path)) {
        http_response_code(404);
        echo json_encode(['ok' => false, 'error' => 'Media not found']);
        exit;
    }
    $ext = strtolower(pathinfo($file, PATHINFO_EXTENSION));
    $mime = match ($ext) {
        'm4a', 'aac' => 'audio/mp4',
        'mp3' => 'audio/mpeg',
        'wav' => 'audio/wav',
        'jpg', 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'webp' => 'image/webp',
        'pdf' => 'application/pdf',
        default => 'application/octet-stream',
    };
    header("Content-Type: $mime");
    header('Content-Length: ' . filesize($path));
    readfile($path);
    exit;
}

if ($action === 'send_push' || $action === 'test_push') {
    $raw = file_get_contents('php://input');
    $data = json_decode($raw ?: '{}', true);
    if (!is_array($data)) {
        $data = [];
    }
    $title = (string) ($data['title'] ?? 'Blue Hour HQ • Live FCM Push');
    $body = (string) ($data['body'] ?? 'Terminated & background push notifications are now active for all 3 Founders.');
    $category = (string) ($data['category'] ?? 'Announcements');
    $targetRoute = (string) ($data['targetRoute'] ?? '/notifications');
    $senderId = (string) ($data['senderId'] ?? '');

    $topics = [];
    if ($action === 'test_push' || !empty($data['includeAllFounders'])) {
        $topics[] = 'blue_hour_hq_founders';
    } elseif (!empty($data['targetFounderIds']) && is_array($data['targetFounderIds'])) {
        foreach ($data['targetFounderIds'] as $fid) {
            $topics[] = 'blue_hour_' . preg_replace('/[^a-zA-Z0-9_-]/', '', (string) $fid);
        }
    } else {
        foreach (['emp-01', 'emp-02', 'emp-03'] as $fid) {
            if ($fid !== $senderId) {
                $topics[] = 'blue_hour_' . $fid;
            }
        }
    }

    $results = [];
    foreach ($topics as $t) {
        $results[] = sendFcmPushToTopic($t, $title, $body, $category, $targetRoute);
    }
    echo json_encode([
        'ok' => true,
        'dispatched' => $results,
    ]);
    exit;
}

if ($action === 'sync' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $raw = file_get_contents('php://input');
    $payload = json_decode($raw ?: '{}', true);
    if (!is_array($payload)) {
        http_response_code(400);
        echo json_encode(['ok' => false, 'error' => 'Invalid JSON payload']);
        exit;
    }

    try {
        $pdo->beginTransaction();

        // 1. Sync Leads
        if (isset($payload['leads']) && is_array($payload['leads'])) {
            $stmt = $pdo->prepare("
                INSERT INTO `leads` (
                    `id`, `lead_code`, `company_name`, `contact_person`, `phone`, `email`,
                    `website`, `location`, `industry`, `source`, `interested_service`,
                    `estimated_budget_inr`, `assigned_employee_name`, `priority`, `status`,
                    `expected_closing_date`, `created_date`, `next_followup_at`, `notes`
                ) VALUES (
                    :id, :lead_code, :company_name, :contact_person, :phone, :email,
                    :website, :location, :industry, :source, :interested_service,
                    :estimated_budget_inr, :assigned_employee_name, :priority, :status,
                    :expected_closing_date, :created_date, :next_followup_at, :notes
                ) ON DUPLICATE KEY UPDATE
                    `company_name` = VALUES(`company_name`),
                    `contact_person` = VALUES(`contact_person`),
                    `phone` = VALUES(`phone`),
                    `email` = VALUES(`email`),
                    `estimated_budget_inr` = VALUES(`estimated_budget_inr`),
                    `assigned_employee_name` = VALUES(`assigned_employee_name`),
                    `priority` = VALUES(`priority`),
                    `status` = VALUES(`status`),
                    `next_followup_at` = VALUES(`next_followup_at`),
                    `notes` = VALUES(`notes`)
            ");
            foreach ($payload['leads'] as $l) {
                $stmt->execute([
                    ':id' => $l['id'],
                    ':lead_code' => $l['leadCode'] ?? 'BH-LD-1001',
                    ':company_name' => $l['companyName'] ?? '',
                    ':contact_person' => $l['contactPerson'] ?? '',
                    ':phone' => $l['phone'] ?? '',
                    ':email' => $l['email'] ?? '',
                    ':website' => $l['website'] ?? '',
                    ':location' => $l['location'] ?? 'Guwahati, Assam',
                    ':industry' => $l['industry'] ?? 'Technology',
                    ':source' => $l['source'] ?? 'Website',
                    ':interested_service' => $l['interestedService'] ?? 'Website Development',
                    ':estimated_budget_inr' => (float) ($l['estimatedBudgetInr'] ?? 0),
                    ':assigned_employee_name' => $l['assignedEmployeeName'] ?? 'Himon Bhuyan',
                    ':priority' => $l['priority'] ?? 'High',
                    ':status' => $l['status'] ?? 'New Lead',
                    ':expected_closing_date' => toMysqlDateTime($l['expectedClosingDate'] ?? null) ?? date('Y-m-d H:i:s'),
                    ':created_date' => toMysqlDateTime($l['createdDate'] ?? null) ?? date('Y-m-d H:i:s'),
                    ':next_followup_at' => toMysqlDateTime($l['nextFollowupAt'] ?? null),
                    ':notes' => $l['notes'] ?? '',
                ]);
            }
        }

        // 2. Sync Follow-ups
        if (isset($payload['followups']) && is_array($payload['followups'])) {
            $stmt = $pdo->prepare("
                INSERT INTO `lead_followups` (
                    `id`, `lead_id`, `company_name`, `assigned_employee`,
                    `followup_type`, `scheduled_at`, `notes`, `is_completed`
                ) VALUES (
                    :id, :lead_id, :company_name, :assigned_employee,
                    :followup_type, :scheduled_at, :notes, :is_completed
                ) ON DUPLICATE KEY UPDATE
                    `scheduled_at` = VALUES(`scheduled_at`),
                    `notes` = VALUES(`notes`),
                    `is_completed` = VALUES(`is_completed`)
            ");
            foreach ($payload['followups'] as $f) {
                $stmt->execute([
                    ':id' => $f['id'],
                    ':lead_id' => $f['leadId'] ?? '',
                    ':company_name' => $f['companyName'] ?? '',
                    ':assigned_employee' => $f['assignedEmployee'] ?? 'Himon Bhuyan',
                    ':followup_type' => $f['followupType'] ?? 'Phone Call',
                    ':scheduled_at' => toMysqlDateTime($f['scheduledAt'] ?? null) ?? date('Y-m-d H:i:s'),
                    ':notes' => $f['notes'] ?? '',
                    ':is_completed' => !empty($f['isCompleted']) ? 1 : 0,
                ]);
            }
        }

        // 3. Sync Clients
        if (isset($payload['clients']) && is_array($payload['clients'])) {
            $stmt = $pdo->prepare("
                INSERT INTO `clients` (
                    `id`, `client_code`, `company_name`, `contact_person`, `email`, `phone`,
                    `website`, `address`, `industry`, `services_purchased_json`, `account_manager`,
                    `status`, `total_billed_inr`, `outstanding_inr`, `active_projects_count`,
                    `onboarded_at`, `notes`
                ) VALUES (
                    :id, :client_code, :company_name, :contact_person, :email, :phone,
                    :website, :address, :industry, :services_purchased_json, :account_manager,
                    :status, :total_billed_inr, :outstanding_inr, :active_projects_count,
                    :onboarded_at, :notes
                ) ON DUPLICATE KEY UPDATE
                    `status` = VALUES(`status`),
                    `total_billed_inr` = VALUES(`total_billed_inr`),
                    `outstanding_inr` = VALUES(`outstanding_inr`),
                    `active_projects_count` = VALUES(`active_projects_count`),
                    `notes` = VALUES(`notes`)
            ");
            foreach ($payload['clients'] as $c) {
                $stmt->execute([
                    ':id' => $c['id'],
                    ':client_code' => $c['clientCode'] ?? 'BH-CL-101',
                    ':company_name' => $c['companyName'] ?? '',
                    ':contact_person' => $c['contactPerson'] ?? '',
                    ':email' => $c['email'] ?? '',
                    ':phone' => $c['phone'] ?? '',
                    ':website' => $c['website'] ?? '',
                    ':address' => $c['address'] ?? '',
                    ':industry' => $c['industry'] ?? '',
                    ':services_purchased_json' => json_encode($c['servicesPurchased'] ?? []),
                    ':account_manager' => $c['accountManager'] ?? 'Himon Bhuyan',
                    ':status' => $c['status'] ?? 'Active',
                    ':total_billed_inr' => (float) ($c['totalBilledInr'] ?? 0),
                    ':outstanding_inr' => (float) ($c['outstandingInr'] ?? 0),
                    ':active_projects_count' => (int) ($c['activeProjectsCount'] ?? 1),
                    ':onboarded_at' => toMysqlDateTime($c['onboardedAt'] ?? null) ?? date('Y-m-d H:i:s'),
                    ':notes' => $c['notes'] ?? '',
                ]);
            }
        }

        // 4. Sync Projects
        if (isset($payload['projects']) && is_array($payload['projects'])) {
            $stmt = $pdo->prepare("
                INSERT INTO `projects` (
                    `id`, `project_code`, `name`, `client_name`, `category`, `description`,
                    `project_manager`, `assigned_team_json`, `start_date`, `deadline`,
                    `budget_inr`, `status`, `progress_percentage`
                ) VALUES (
                    :id, :project_code, :name, :client_name, :category, :description,
                    :project_manager, :assigned_team_json, :start_date, :deadline,
                    :budget_inr, :status, :progress_percentage
                ) ON DUPLICATE KEY UPDATE
                    `status` = VALUES(`status`),
                    `progress_percentage` = VALUES(`progress_percentage`),
                    `budget_inr` = VALUES(`budget_inr`)
            ");
            foreach ($payload['projects'] as $p) {
                $stmt->execute([
                    ':id' => $p['id'],
                    ':project_code' => $p['projectCode'] ?? 'BH-PRJ-101',
                    ':name' => $p['name'] ?? '',
                    ':client_name' => $p['clientName'] ?? '',
                    ':category' => $p['category'] ?? '',
                    ':description' => $p['description'] ?? '',
                    ':project_manager' => $p['projectManager'] ?? 'Himon Bhuyan',
                    ':assigned_team_json' => json_encode($p['assignedTeam'] ?? []),
                    ':start_date' => toMysqlDateTime($p['startDate'] ?? null) ?? date('Y-m-d H:i:s'),
                    ':deadline' => toMysqlDateTime($p['deadline'] ?? null) ?? date('Y-m-d H:i:s'),
                    ':budget_inr' => (float) ($p['budgetInr'] ?? 0),
                    ':status' => $p['status'] ?? 'In Progress',
                    ':progress_percentage' => (int) ($p['progressPercentage'] ?? 0),
                ]);
            }
        }

        // 5. Sync Tasks
        if (isset($payload['tasks']) && is_array($payload['tasks'])) {
            $stmt = $pdo->prepare("
                INSERT INTO `tasks` (
                    `id`, `task_code`, `title`, `description`, `project_id`, `project_name`,
                    `assigned_employee`, `priority`, `status`, `start_date`, `deadline`
                ) VALUES (
                    :id, :task_code, :title, :description, :project_id, :project_name,
                    :assigned_employee, :priority, :status, :start_date, :deadline
                ) ON DUPLICATE KEY UPDATE
                    `status` = VALUES(`status`),
                    `priority` = VALUES(`priority`),
                    `assigned_employee` = VALUES(`assigned_employee`)
            ");
            foreach ($payload['tasks'] as $t) {
                $stmt->execute([
                    ':id' => $t['id'],
                    ':task_code' => $t['taskCode'] ?? 'BH-TSK-101',
                    ':title' => $t['title'] ?? '',
                    ':description' => $t['description'] ?? '',
                    ':project_id' => $t['projectId'] ?? 'proj-general',
                    ':project_name' => $t['projectName'] ?? 'Studio Sprint',
                    ':assigned_employee' => $t['assignedEmployee'] ?? 'Himon Bhuyan',
                    ':priority' => $t['priority'] ?? 'High',
                    ':status' => $t['status'] ?? 'To Do',
                    ':start_date' => toMysqlDateTime($t['startDate'] ?? null) ?? date('Y-m-d H:i:s'),
                    ':deadline' => toMysqlDateTime($t['deadline'] ?? null) ?? date('Y-m-d H:i:s'),
                ]);
            }
        }

        // 6. Sync Meetings
        if (isset($payload['meetings']) && is_array($payload['meetings'])) {
            $stmt = $pdo->prepare("
                INSERT INTO `meetings` (
                    `id`, `meeting_code`, `title`, `client_or_company`, `description`,
                    `start_time`, `end_time`, `meeting_type`, `location`, `online_meeting_link`,
                    `participants_json`, `assigned_employee`, `notes`
                ) VALUES (
                    :id, :meeting_code, :title, :client_or_company, :description,
                    :start_time, :end_time, :meeting_type, :location, :online_meeting_link,
                    :participants_json, :assigned_employee, :notes
                ) ON DUPLICATE KEY UPDATE
                    `start_time` = VALUES(`start_time`),
                    `end_time` = VALUES(`end_time`),
                    `notes` = VALUES(`notes`)
            ");
            foreach ($payload['meetings'] as $m) {
                $stmt->execute([
                    ':id' => $m['id'],
                    ':meeting_code' => $m['meetingCode'] ?? 'BH-MTG-101',
                    ':title' => $m['title'] ?? '',
                    ':client_or_company' => $m['clientOrCompany'] ?? '',
                    ':description' => $m['description'] ?? '',
                    ':start_time' => toMysqlDateTime($m['startTime'] ?? null) ?? date('Y-m-d H:i:s'),
                    ':end_time' => toMysqlDateTime($m['endTime'] ?? null) ?? date('Y-m-d H:i:s'),
                    ':meeting_type' => $m['meetingType'] ?? 'Client Meeting',
                    ':location' => $m['location'] ?? 'Google Meet',
                    ':online_meeting_link' => $m['onlineMeetingLink'] ?? null,
                    ':participants_json' => json_encode($m['participants'] ?? []),
                    ':assigned_employee' => $m['assignedEmployee'] ?? 'Himon Bhuyan',
                    ':notes' => $m['notes'] ?? '',
                ]);
            }
        }

        // 7. Sync Proposals
        if (isset($payload['proposals']) && is_array($payload['proposals'])) {
            $stmt = $pdo->prepare("
                INSERT INTO `proposals` (
                    `id`, `proposal_code`, `client_or_lead_name`, `title`, `service_category`,
                    `subtotal_inr`, `discount_inr`, `gst_amount_inr`, `total_amount_inr`,
                    `valid_until`, `status`, `prepared_by`
                ) VALUES (
                    :id, :proposal_code, :client_or_lead_name, :title, :service_category,
                    :subtotal_inr, :discount_inr, :gst_amount_inr, :total_amount_inr,
                    :valid_until, :status, :prepared_by
                ) ON DUPLICATE KEY UPDATE
                    `status` = VALUES(`status`),
                    `total_amount_inr` = VALUES(`total_amount_inr`)
            ");
            foreach ($payload['proposals'] as $pr) {
                $stmt->execute([
                    ':id' => $pr['id'],
                    ':proposal_code' => $pr['proposalCode'] ?? 'BH-PRP-101',
                    ':client_or_lead_name' => $pr['clientOrLeadName'] ?? '',
                    ':title' => $pr['title'] ?? '',
                    ':service_category' => $pr['serviceCategory'] ?? '',
                    ':subtotal_inr' => (float) ($pr['subtotalInr'] ?? 0),
                    ':discount_inr' => (float) ($pr['discountInr'] ?? 0),
                    ':gst_amount_inr' => (float) ($pr['gstAmountInr'] ?? 0),
                    ':total_amount_inr' => (float) ($pr['totalAmountInr'] ?? 0),
                    ':valid_until' => toMysqlDateTime($pr['validUntil'] ?? null) ?? date('Y-m-d H:i:s'),
                    ':status' => $pr['status'] ?? 'Sent',
                    ':prepared_by' => $pr['preparedBy'] ?? 'Himon Bhuyan',
                ]);
            }
        }

        // 8. Sync Invoices
        if (isset($payload['invoices']) && is_array($payload['invoices'])) {
            $stmt = $pdo->prepare("
                INSERT INTO `invoices` (
                    `id`, `invoice_number`, `client_name`, `project_name`, `service_category`,
                    `issue_date`, `due_date`, `total_amount_inr`, `paid_amount_inr`, `status`
                ) VALUES (
                    :id, :invoice_number, :client_name, :project_name, :service_category,
                    :issue_date, :due_date, :total_amount_inr, :paid_amount_inr, :status
                ) ON DUPLICATE KEY UPDATE
                    `paid_amount_inr` = VALUES(`paid_amount_inr`),
                    `status` = VALUES(`status`)
            ");
            foreach ($payload['invoices'] as $inv) {
                $stmt->execute([
                    ':id' => $inv['id'],
                    ':invoice_number' => $inv['invoiceNumber'] ?? 'BH-INV-101',
                    ':client_name' => $inv['clientName'] ?? '',
                    ':project_name' => $inv['projectName'] ?? '',
                    ':service_category' => $inv['serviceCategory'] ?? '',
                    ':issue_date' => toMysqlDateTime($inv['issueDate'] ?? null) ?? date('Y-m-d H:i:s'),
                    ':due_date' => toMysqlDateTime($inv['dueDate'] ?? null) ?? date('Y-m-d H:i:s'),
                    ':total_amount_inr' => (float) ($inv['totalAmountInr'] ?? 0),
                    ':paid_amount_inr' => (float) ($inv['paidAmountInr'] ?? 0),
                    ':status' => $inv['status'] ?? 'Sent',
                ]);
            }
        }

        // 9. Sync Expenses
        if (isset($payload['expenses']) && is_array($payload['expenses'])) {
            $stmt = $pdo->prepare("
                INSERT INTO `expenses` (
                    `id`, `expense_code`, `category`, `vendor_name`, `description`, `amount_inr`, `expense_date`
                ) VALUES (
                    :id, :expense_code, :category, :vendor_name, :description, :amount_inr, :expense_date
                ) ON DUPLICATE KEY UPDATE
                    `amount_inr` = VALUES(`amount_inr`),
                    `description` = VALUES(`description`)
            ");
            foreach ($payload['expenses'] as $ex) {
                $stmt->execute([
                    ':id' => $ex['id'],
                    ':expense_code' => $ex['expenseCode'] ?? 'BH-EXP-101',
                    ':category' => $ex['category'] ?? '',
                    ':vendor_name' => $ex['vendorName'] ?? '',
                    ':description' => $ex['description'] ?? '',
                    ':amount_inr' => (float) ($ex['amountInr'] ?? 0),
                    ':expense_date' => toMysqlDateTime($ex['date'] ?? null) ?? date('Y-m-d H:i:s'),
                ]);
            }
        }

        // 10. Sync Notifications (replace so swiped/cleared alerts stay removed)
        if (isset($payload['notifications']) && is_array($payload['notifications'])) {
            $pdo->exec("DELETE FROM `notifications`");
            $stmt = $pdo->prepare("
                INSERT INTO `notifications` (
                    `id`, `category`, `title`, `body`, `timestamp`, `is_read`,
                    `target_route`, `entity_id`, `actions_json`
                ) VALUES (
                    :id, :category, :title, :body, :timestamp, :is_read,
                    :target_route, :entity_id, :actions_json
                ) ON DUPLICATE KEY UPDATE
                    `is_read` = VALUES(`is_read`)
            ");
            foreach ($payload['notifications'] as $n) {
                $stmt->execute([
                    ':id' => $n['id'],
                    ':category' => $n['category'] ?? 'All',
                    ':title' => $n['title'] ?? '',
                    ':body' => $n['body'] ?? '',
                    ':timestamp' => toMysqlDateTime($n['timestamp'] ?? null) ?? date('Y-m-d H:i:s'),
                    ':is_read' => !empty($n['isRead']) ? 1 : 0,
                    ':target_route' => $n['targetRoute'] ?? null,
                    ':entity_id' => $n['entityId'] ?? null,
                    ':actions_json' => json_encode($n['actions'] ?? []),
                ]);
            }
        }

        // 11. Sync Chat Messages & Thread Unreads
        if (isset($payload['chatThreadUnreads']) && is_array($payload['chatThreadUnreads'])) {
            $unreadStmt = $pdo->prepare("UPDATE `chat_threads` SET `unread_count` = :u WHERE `id` = :id");
            foreach ($payload['chatThreadUnreads'] as $tid => $uCount) {
                $unreadStmt->execute([':u' => (int) $uCount, ':id' => (string) $tid]);
            }
        }

        if (isset($payload['chatMessages']) && is_array($payload['chatMessages'])) {
            $delStmt = $pdo->prepare("DELETE FROM `chat_messages` WHERE `thread_id` = :tid");
            $msgStmt = $pdo->prepare("
                INSERT INTO `chat_messages` (
                    `id`, `thread_id`, `sender_id`, `sender_name`, `sender_role`, `body`,
                    `timestamp`, `message_type`, `attachment_name`, `attachment_size`,
                    `voice_duration_sec`, `reply_to_sender`, `reply_to_preview`,
                    `reactions_json`, `is_pinned`
                ) VALUES (
                    :id, :thread_id, :sender_id, :sender_name, :sender_role, :body,
                    :timestamp, :message_type, :attachment_name, :attachment_size,
                    :voice_duration_sec, :reply_to_sender, :reply_to_preview,
                    :reactions_json, :is_pinned
                )
            ");
            $updThreadStmt = $pdo->prepare("
                UPDATE `chat_threads`
                SET `last_message_preview` = :preview, `last_activity` = :activity
                WHERE `id` = :tid
            ");

            foreach ($payload['chatMessages'] as $threadId => $msgs) {
                if (!is_array($msgs)) continue;
                $delStmt->execute([':tid' => (string) $threadId]);
                $lastPreview = 'No messages yet';
                $lastActivity = date('Y-m-d H:i:s');

                foreach ($msgs as $m) {
                    $dt = toMysqlDateTime($m['timestamp'] ?? null) ?? date('Y-m-d H:i:s');
                    $msgStmt->execute([
                        ':id' => $m['id'],
                        ':thread_id' => (string) $threadId,
                        ':sender_id' => $m['senderId'] ?? 'emp-01',
                        ':sender_name' => $m['senderName'] ?? 'Himon Bhuyan',
                        ':sender_role' => $m['senderRole'] ?? 'Founder',
                        ':body' => $m['body'] ?? '',
                        ':timestamp' => $dt,
                        ':message_type' => $m['messageType'] ?? 'text',
                        ':attachment_name' => $m['attachmentName'] ?? null,
                        ':attachment_size' => $m['attachmentSize'] ?? null,
                        ':voice_duration_sec' => isset($m['voiceDurationSec']) ? (int) $m['voiceDurationSec'] : null,
                        ':reply_to_sender' => $m['replyToSender'] ?? null,
                        ':reply_to_preview' => $m['replyToPreview'] ?? null,
                        ':reactions_json' => json_encode($m['reactions'] ?? new stdClass()),
                        ':is_pinned' => !empty($m['isPinned']) ? 1 : 0,
                    ]);
                    $lastPreview = ($m['senderName'] ?? 'Founder') . ': ' . ($m['body'] ?? '');
                    $lastActivity = $dt;
                }
                $updThreadStmt->execute([
                    ':preview' => mb_substr($lastPreview, 0, 250),
                    ':activity' => $lastActivity,
                    ':tid' => (string) $threadId,
                ]);
            }
        }

        // Prune records deleted in app across synced modules
        $pruneMap = [
            'leads' => 'leads',
            'followups' => 'lead_followups',
            'clients' => 'clients',
            'projects' => 'projects',
            'tasks' => 'tasks',
            'meetings' => 'meetings',
            'proposals' => 'proposals',
            'invoices' => 'invoices',
            'expenses' => 'expenses',
        ];
        foreach ($pruneMap as $jsonKey => $tbl) {
            if (!isset($payload[$jsonKey]) || !is_array($payload[$jsonKey])) continue;
            $ids = array_values(array_filter(array_map(fn($r) => $r['id'] ?? null, $payload[$jsonKey])));
            if (empty($ids)) {
                $pdo->exec("DELETE FROM `$tbl`");
            } else {
                $placeholders = implode(',', array_fill(0, count($ids), '?'));
                $del = $pdo->prepare("DELETE FROM `$tbl` WHERE `id` NOT IN ($placeholders)");
                $del->execute($ids);
            }
        }

        $pdo->commit();
        echo json_encode([
            'ok' => true,
            'synced_at' => date('c'),
            'database' => 'blue_hour_hq',
        ]);
        exit;
    } catch (Throwable $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        http_response_code(500);
        echo json_encode([
            'ok' => false,
            'error' => $e->getMessage(),
        ]);
        exit;
    }
}

// Default: GET ?action=pull — Return all live relational records from MySQL `blue_hour_hq`
$leads = array_map(fn($r) => [
    'id' => $r['id'],
    'leadCode' => $r['lead_code'],
    'companyName' => $r['company_name'],
    'contactPerson' => $r['contact_person'],
    'phone' => $r['phone'],
    'email' => $r['email'],
    'website' => $r['website'],
    'location' => $r['location'],
    'industry' => $r['industry'],
    'source' => $r['source'],
    'interestedService' => $r['interested_service'],
    'estimatedBudgetInr' => (float) $r['estimated_budget_inr'],
    'assignedEmployeeName' => $r['assigned_employee_name'],
    'priority' => $r['priority'],
    'status' => $r['status'],
    'expectedClosingDate' => toIso8601($r['expected_closing_date']),
    'createdDate' => toIso8601($r['created_date']),
    'nextFollowupAt' => toIso8601($r['next_followup_at']),
    'notes' => $r['notes'] ?? '',
], $pdo->query("SELECT * FROM `leads` ORDER BY `created_date` DESC")->fetchAll());

$followups = array_map(fn($r) => [
    'id' => $r['id'],
    'leadId' => $r['lead_id'],
    'companyName' => $r['company_name'],
    'assignedEmployee' => $r['assigned_employee'],
    'followupType' => $r['followup_type'],
    'scheduledAt' => toIso8601($r['scheduled_at']),
    'notes' => $r['notes'] ?? '',
    'isCompleted' => (bool) $r['is_completed'],
], $pdo->query("SELECT * FROM `lead_followups` ORDER BY `scheduled_at` ASC")->fetchAll());

$clients = array_map(fn($r) => [
    'id' => $r['id'],
    'clientCode' => $r['client_code'],
    'companyName' => $r['company_name'],
    'contactPerson' => $r['contact_person'],
    'email' => $r['email'],
    'phone' => $r['phone'],
    'website' => $r['website'],
    'address' => $r['address'],
    'industry' => $r['industry'],
    'servicesPurchased' => json_decode($r['services_purchased_json'] ?: '[]', true) ?: [],
    'accountManager' => $r['account_manager'],
    'status' => $r['status'],
    'totalBilledInr' => (float) $r['total_billed_inr'],
    'outstandingInr' => (float) $r['outstanding_inr'],
    'activeProjectsCount' => (int) $r['active_projects_count'],
    'onboardedAt' => toIso8601($r['onboarded_at']),
    'notes' => $r['notes'] ?? '',
], $pdo->query("SELECT * FROM `clients` ORDER BY `onboarded_at` DESC")->fetchAll());

$projects = array_map(fn($r) => [
    'id' => $r['id'],
    'projectCode' => $r['project_code'],
    'name' => $r['name'],
    'clientName' => $r['client_name'],
    'category' => $r['category'],
    'description' => $r['description'] ?? '',
    'projectManager' => $r['project_manager'],
    'assignedTeam' => json_decode($r['assigned_team_json'] ?: '[]', true) ?: [],
    'startDate' => toIso8601($r['start_date']),
    'deadline' => toIso8601($r['deadline']),
    'budgetInr' => (float) $r['budget_inr'],
    'status' => $r['status'],
    'progressPercentage' => (int) $r['progress_percentage'],
], $pdo->query("SELECT * FROM `projects` ORDER BY `start_date` DESC")->fetchAll());

$tasks = array_map(fn($r) => [
    'id' => $r['id'],
    'taskCode' => $r['task_code'],
    'title' => $r['title'],
    'description' => $r['description'] ?? '',
    'projectId' => $r['project_id'],
    'projectName' => $r['project_name'],
    'assignedEmployee' => $r['assigned_employee'],
    'priority' => $r['priority'],
    'status' => $r['status'],
    'startDate' => toIso8601($r['start_date']),
    'deadline' => toIso8601($r['deadline']),
], $pdo->query("SELECT * FROM `tasks` ORDER BY `deadline` ASC")->fetchAll());

$meetings = array_map(fn($r) => [
    'id' => $r['id'],
    'meetingCode' => $r['meeting_code'],
    'title' => $r['title'],
    'clientOrCompany' => $r['client_or_company'],
    'description' => $r['description'] ?? '',
    'startTime' => toIso8601($r['start_time']),
    'endTime' => toIso8601($r['end_time']),
    'meetingType' => $r['meeting_type'],
    'location' => $r['location'],
    'onlineMeetingLink' => $r['online_meeting_link'],
    'participants' => json_decode($r['participants_json'] ?: '[]', true) ?: [],
    'assignedEmployee' => $r['assigned_employee'],
    'notes' => $r['notes'] ?? '',
], $pdo->query("SELECT * FROM `meetings` ORDER BY `start_time` ASC")->fetchAll());

$proposals = array_map(fn($r) => [
    'id' => $r['id'],
    'proposalCode' => $r['proposal_code'],
    'clientOrLeadName' => $r['client_or_lead_name'],
    'title' => $r['title'],
    'serviceCategory' => $r['service_category'],
    'subtotalInr' => (float) $r['subtotal_inr'],
    'discountInr' => (float) $r['discount_inr'],
    'gstAmountInr' => (float) $r['gst_amount_inr'],
    'totalAmountInr' => (float) $r['total_amount_inr'],
    'validUntil' => toIso8601($r['valid_until']),
    'status' => $r['status'],
    'preparedBy' => $r['prepared_by'],
], $pdo->query("SELECT * FROM `proposals` ORDER BY `updated_at` DESC")->fetchAll());

$invoices = array_map(fn($r) => [
    'id' => $r['id'],
    'invoiceNumber' => $r['invoice_number'],
    'clientName' => $r['client_name'],
    'projectName' => $r['project_name'],
    'serviceCategory' => $r['service_category'],
    'issueDate' => toIso8601($r['issue_date']),
    'dueDate' => toIso8601($r['due_date']),
    'totalAmountInr' => (float) $r['total_amount_inr'],
    'paidAmountInr' => (float) $r['paid_amount_inr'],
    'status' => $r['status'],
], $pdo->query("SELECT * FROM `invoices` ORDER BY `issue_date` DESC")->fetchAll());

$expenses = array_map(fn($r) => [
    'id' => $r['id'],
    'expenseCode' => $r['expense_code'],
    'category' => $r['category'],
    'vendorName' => $r['vendor_name'],
    'description' => $r['description'] ?? '',
    'amountInr' => (float) $r['amount_inr'],
    'date' => toIso8601($r['expense_date']),
], $pdo->query("SELECT * FROM `expenses` ORDER BY `expense_date` DESC")->fetchAll());

$notifications = array_map(fn($r) => [
    'id' => $r['id'],
    'category' => $r['category'],
    'title' => $r['title'],
    'body' => $r['body'],
    'timestamp' => toIso8601($r['timestamp']),
    'isRead' => (bool) $r['is_read'],
    'targetRoute' => $r['target_route'],
    'entityId' => $r['entity_id'],
    'actions' => json_decode($r['actions_json'] ?: '[]', true) ?: [],
], $pdo->query("SELECT * FROM `notifications` ORDER BY `timestamp` DESC")->fetchAll());

$chatThreadUnreads = [];
foreach ($pdo->query("SELECT `id`, `unread_count` FROM `chat_threads`")->fetchAll() as $tr) {
    $chatThreadUnreads[$tr['id']] = (int) $tr['unread_count'];
}

$chatMessages = [];
foreach ($pdo->query("SELECT * FROM `chat_messages` ORDER BY `timestamp` ASC")->fetchAll() as $m) {
    $tid = $m['thread_id'];
    if (!isset($chatMessages[$tid])) {
        $chatMessages[$tid] = [];
    }
    $decodedReactions = json_decode($m['reactions_json'] ?: '{}', true);
    $chatMessages[$tid][] = [
        'id' => $m['id'],
        'threadId' => $tid,
        'senderId' => $m['sender_id'],
        'senderName' => $m['sender_name'],
        'senderRole' => $m['sender_role'],
        'body' => $m['body'],
        'timestamp' => toIso8601($m['timestamp']),
        'isMe' => true,
        'messageType' => $m['message_type'],
        'attachmentName' => $m['attachment_name'],
        'attachmentSize' => $m['attachment_size'],
        'voiceDurationSec' => $m['voice_duration_sec'] !== null ? (int) $m['voice_duration_sec'] : null,
        'replyToSender' => $m['reply_to_sender'],
        'replyToPreview' => $m['reply_to_preview'],
        'reactions' => is_array($decodedReactions) ? $decodedReactions : new stdClass(),
        'isPinned' => (bool) $m['is_pinned'],
    ];
}

echo json_encode([
    'ok' => true,
    'database' => 'blue_hour_hq',
    'leads' => $leads,
    'followups' => $followups,
    'clients' => $clients,
    'projects' => $projects,
    'tasks' => $tasks,
    'meetings' => $meetings,
    'proposals' => $proposals,
    'invoices' => $invoices,
    'expenses' => $expenses,
    'notifications' => $notifications,
    'chatThreadUnreads' => $chatThreadUnreads,
    'chatMessages' => $chatMessages,
]);

